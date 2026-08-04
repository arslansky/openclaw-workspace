# AI Agent CRM 完整架構設計方案

**設計原則：一層嚴謹，一層彈性，兩層唔好撈埋**

---

## 1. 核心架構分層

| 層 | 職責 | 類型 |
|---|---|---|
| 用戶層 | 自然語言輸入 / 輸出呈現 | 彈性 |
| Agent 層 | 意圖分類、決策路由、對話管理 | 彈性 |
| Tools 層 | 結構化 I/O，Pydantic Schema，統一介面 | 彈性 |
| 嚴謹層 | 狀態機、權限、Validation、審計 | **嚴謹 ★** |
| 數據層 | PostgreSQL + Audit Log，所有寫操作 immutable | **嚴謹 ★** |

---

## 2. Tool 執行流程

1. LLM 分析用戶輸入，提出 action（自然語言）
2. Structured Output（Pydantic Schema）— 唔係直接執行
3. Tool Function 接收結構化 input
4. 嚴謹層校驗：狀態機、權限、Validation
5a. Pass → 寫 DB + Audit Log → return structured result
5b. Fail → return 具體 error → LLM 重新組織回覆用戶

---

## 3. Tool Definitions

### Lead Tools

**`create_lead(name, email, company?, source?)`**
→ Validation: name non-empty, email format | 業務: duplicate company+email 阻擋 | 寫: DB insert, status="new" | Audit: action="lead.created"

**`update_lead(lead_id, **fields)`**
→ Validation: lead exists, state allows update | 業務: status transition rules | 寫: DB update | Audit: action="lead.updated", changes=before/after

**`qualify_lead(lead_id)`**
→ Precondition: lead.status IN (new, contact_made) | 業務: at least one contact required | 寫: status="qualified", qualified_at=now | Audit: action="lead.qualified"

**`assign_lead(lead_id, owner_id)`**
→ Validation: owner exists, owner.role=sales | 業務: reassignment audit | 寫: owner_id update | Audit: action="lead.assigned"

**`get_my_leads(status?, page?)`**
→ Row-level filter always applied: WHERE owner_id = :current_user | 分頁返回

---

### Opportunity Tools

**`create_opportunity(lead_id, title, value?)`**
→ Precondition: lead.status = qualified | Validation: duplicate opp per lead check | 寫: DB insert, stage="qualified" | Audit: action="opportunity.created"

**`update_stage(opp_id, new_stage, reason?)`**
→ State machine enforced (see Section 4) | Validation: transition allowed | 寫: DB update, stage_changed_at=now | Audit: action="opportunity.stage_changed"
→ Blocked: return specific error → LLM rephrases

**`add_task(opp_id?, lead_id?, title, due_date?)`**
→ Validation: either opp_id or lead_id required | 寫: DB insert | Audit: action="task.created"

**`send_email(to, subject, body)`**
→ Always draft mode | 寫: DB insert, status="draft" | Audit: action="email.drafted"
→ Requires explicit confirmation before send

**`get_opportunity_history(opp_id)`**
→ Immutable audit trail | SELECT FROM audit_log WHERE entity_type='opportunity' AND entity_id=opp_id

---

### Contact Tools

**`create_contact(lead_id, name, email?, phone?)`**
→ Validation: lead exists | 業務: link to company | 寫: DB insert | Audit: action="contact.created"

**`link_contact_to_opportunity(contact_id, opp_id)`**
→ Validation: contact exists, same company check | 業務: duplicate link check | 寫: contacts.opp_id update | Audit: action="contact.linked_to_opportunity"

---

## 4. State Machines

### Lead State Machine

```
new → contact_made → qualified → (create opportunity)
  ↘ unqualified (blocked)
```

**Transition Rules:**
- new → contact_made: add_contact() called
- contact_made → qualified: qualify_lead() + at least one contact
- qualified → unqualified: BLOCKED

---

### Opportunity State Machine

```
qualified → discovery → proposal → negotiation → won ✓
  ↘ lost ✗
```

**Transition Rules:**
- qualified → discovery: add_contact() linked to this opp
- discovery → proposal: send_quote() called, quote prepared
- proposal → negotiation: quote sent to contact
- negotiation → won: proposal_sent=true, value>0, (value<=approval_limit OR approved=true)
- negotiation → lost: close_lost() + reason_code required — BLOCKED if no reason

---

## 5. Database Schema

**Core Tables:**

```
users — id (PK), email, name, role (admin/manager/sales), team_id (FK → teams), created_at

leads — id (PK), name, email, company, source, status (new/contact_made/qualified/unqualified), owner_id (FK → users), qualified_at, created_at/updated_at

opportunities — id (PK), title, value, stage (qualified/discovery/proposal/negotiation/won/lost), lead_id (FK), owner_id (FK), stage_changed_at, expected_close, lost_reason, created_at/updated_at

tasks — id (PK), title, description, status (pending/in_progress/completed/cancelled), opp_id (FK nullable), lead_id (FK nullable), assigned_to (FK → users), due_date, completed_at, created_at

contacts — id (PK), name, email/phone/role, company_id (FK → leads), opp_id (FK nullable), is_primary, created_at

emails — id (PK), opp_id (FK nullable), lead_id (FK nullable), sender_id (FK → users), direction (inbound/outbound), subject/body_preview, status (draft/sent/delivered/failed), sent_at, created_at

audit_log — id (PK), entity_type, entity_id, action, actor_id (FK → users), actor_type (user/agent/system), changes (JSONB before/after), reason (for state transitions), created_at
```

⚠️ **NO UPDATE/DELETE allowed** — DB trigger enforces immutability

---

**Relationships:**

```
users ──teams
    └── leads (owner_id FK)
        ──contacts (company_id FK)
            └── opportunities (lead_id FK, owner_id FK)
                ├── tasks (opp_id FK, assigned_to FK)
                └── emails (opp_id FK, sender_id FK)
                    └── audit_log (immutable)
```

---

## 6. Row-Level Security

| Role | SELECT | MUTATION |
|------|--------|---------|
| admin | All records in their team | All records in their team |
| manager | Own + reports records | Own + reports records |
| sales | **owner_id = current_user.id ONLY** | owner_id = current_user.id ONLY |
| system (agent) | ALL via audit context | mutation via Tools only |

**Special Restrictions:**
- `lost_reason`: Manager+ only. Sales cannot see other users' lost reasons
- `audit_log writes`: Only Tools / system. No direct INSERT allowed
- `audit_log deletes`: **PROHIBITED. DB trigger blocks UPDATE/DELETE**
- `email auto-send`: Always draft mode by default. Requires explicit confirmation
- `high-value deal approval`: Value > manager_approval_limit requires explicit approval task

---

**版權沒有，隨便用**
