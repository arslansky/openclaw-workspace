# SOP Master｜軟件設計思考手冊

> **目的：** 設計軟件 / application 時，確保考慮周全，唔漏嘢，知道幾時用咩方法。
> **用法：** 開始新 project 前當 checklist 睇；設計過程中當 decision log 用；完成後當 lessons learned 記錄。
> **維護：** 每個 lesson 喺實際 project 用過之後驗證，修訂結論。

---

## 📋 導航目錄

```
Phase 1｜確認問題
  └── 5 條必答 + 常見陷阱

Phase 2｜架構考慮（13 sections）
  §1  複雜度評估
  §2  架構模式（Monolith / Microservices / Event-Driven）
  §3  數據架構
  §4  Statelessness（水平擴展前提）
  §5  Caching（CDN / Redis / Query Cache）
  §6  CAP Theorem（一致性 vs 可用性）
  §7  SQL vs NoSQL（ACID vs BASE）
  §8  API Design（REST vs GraphQL）
  §9  大規模數據處理（RAG）
  §10 存儲架構（Object Store / CDN）
  §11 認證 AuthN + 授權 AuthZ
  §12 Agent Memory Architecture
  §13 Multi-Agent Systems

Phase 3｜語言 / 框架選擇
  └── 語言矩陣 + Auth Stack 矩陣

Phase 4｜操作生命週期
  └── 部署 + 備份 + 監控

Phase 5｜知識累積
  └── 三層框架 + Decision Log

Phase 6｜常見陷阱
  └── 架構陷阱 + 團隊陷阱

Phase 7｜維護 SOP
  └── Review 節奏 + 觸發條件
```

**📚 知識來源索引：**

| Source | 主題 |
|--------|------|
| `iX8g4LqF8p8` | AuthN vs AuthZ、JWT、OAuth2、OIDC、SSO |
| `NQZqET-jjws` | RAG、Hybrid retrieval、Grounded generation |
| `ka_WCmNdybE` | Object Store、Pre-signed URL、Async Queue |
| `HAoUVWO7ers` | Multi-Agent、Strict Constraint、Trace+Review |
| Maddie（9min）| Statelessness、Caching、CAP、SQL vs NoSQL、API Design |
| Dat（27min）| Agent Memory Architecture、5 diagnostic questions |
| 知識庫熔爐 auth.md | Auth implementation cheat sheet |

**🎯 三句核心話（隨時記得）：**

> 1. **整 auth** → AuthN 定 AuthZ？JWT 定 OAuth2 定 OIDC？
> 2. **整 RAG / AI** → 90% effort 放 data pipeline，唔係 model
> 3. **整 file upload** → Binary 放 Object Store，API 只做 metadata

---

## 🔲 第一階段：確認眞正要解嘅問題

> *「我係想整嘢，定係想滿足某個更深嘅需求？」*

### 問題清單（開始前必答）

- [ ] **核心問題係乜？** 用一句話寫出嚟
- [ ] **失敗模式係邊個？** 依家點搞？痛點係乜？
- [ ] **幾時知幾時做得？** 用咩標準驗收？
- [ ] **係技術問題，定係組織問題？** （技術問題有 technical solution，組織問題要改流程）
- [ ] **係呢個問題，定係症狀？** （例如：慢係症狀，點解慢先係問題）

### 常見陷阱

| 陷阱 | 徵兆 | 正確做法 |
|------|------|----------|
| **Solution looking for a problem** | 未確定問題就開始諗 architecture | 先寫 problem statement |
| **Scope creep** | 「既然整開，不如加...」 | 每加一個 requirement 問：係咪解決緊原本嗰個問題？ |
| **Technology bingo** | 「我用 microservices！」「我用 AI！」 | 先問：呢個技術解決咩問題？ |

---

## 🏗️ 第二階段：架構考慮（Architecture）

> *「確定解法之前，先確定架構方向。」*

### 1. 系統複雜度評估

| 維度 | 問題 | 目的 |
|------|------|------|
| **Scale** | 要 handle 幾多用戶/數據？ | 决定 scaling 策略 |
| **Consistency vs Availability** | 資料要幾時啱？容許幾多延遲？ | 决定 CAP 取向 |
| **Change rate** | 業務邏輯改幾快？ | 决定耦合程度 |
| **Team size** | 幾多人開發/維護？ | 决定團隊邊界 |

### 2. 架構模式決策樹

```
問：係單一系統定分佈式？
├── 單一系統（Monolith）
│   ├── 適合：中小規模、團隊 < 10 人、快速疇代
│   ├── 優點：簡單、deploy 快、debug 容易
│   └── 缺點：scale 困難、一個模块爛成個爛
│
├── 微服務（Microservices）
│   ├── 適合：大規模、需要獨立 scale、不同團隊
│   ├── 優點：獨立 deploy、 Fault isolation、技術灵活
│   └── 缺點：複雜度高、network latency分佈式事務
│
└── 事件驅動（Event-Driven）
    ├── 適合：實時反應、多系統整合、處理大量 async 事件
    ├── 優點：解耦、擴展性强、容許 consumer 离线
    └── 缺點：最終一致性、debug 難、事件版本管理

問：同步定異步？
├── 同步（REST/gRPC）
│   └── 適合：需要即時結果、短操作
└── 異步（Message Queue/Event Bus）
    └── 適合：長時間操作、多消費者、不需要即時確認
```

### 3. 數據架構

| 場景 | 推薦 |
|------|------|
| 結構化關係數據、交易完整性 | PostgreSQL |
| 大量寫入、時序數據 | 追加寫入（日誌、events） |
| 靈活 schema、快速疇代 | PostgreSQL JSONB / SQLite |
| 簡單 key-value、快 | Redis / SQLite |
| 全文搜索 | PostgreSQL full-text / Elasticsearch |
| 檔案存儲 | S3-compatible object storage |

**數據所有權原則：**
> 每個 service/module 係自己數據嘅 owner；其他 module 要訪問，必須透過 API，唔可以直接讀另一個 module 嘅 database。

### 4. Statelessness（水平擴展前提）

> ⚠️ **問「點擴展」之前，先問「每台 server 持有咩狀態？」**

**咩係 Stateless：**
- Server 不記得任何先前請求嘅信息
- 每個請求攜帶處理所需一切（通常係 client token）
- 每次請求都係新相見

**有狀態嘅問題（Sticky Session）：**
```
User A → Server 1（記住 user A 登入狀態）
User B → Server 2（記住 user B 登入狀態）
```
- Load balancer 無法自由路由——某啲 user 必須回到某台特定 server
- 如果果台 server 壊咗，user session 就 lost
- 唔可以随意增減 server

**解決方案：**
- 將狀態卸載到共享存储（**Redis / 分佈式 cache**）
- 每台 server 變得相同——可以自由替換
- Load balancer 自由路由
- 獲得真正嘅 fault tolerance

**實際决策：**
```
問：每台 server 持有咩狀態？呢啲狀態應該存喺邊度？

如果係 user session → Redis（shared, fast, TTL built-in）
如果係 file/blob → Object Store
如果係 query result cache → Redis
如果係持久化數據 → Database
```

### 5. Caching（速度 vs 新鮮度）

> **瓶頸喺邊度？數據可以容忍幾舊？** 呢兩個問題决定用咩 cache layer。

**三種 Cache 層次：**

| 層次 | 位置 | 用途 |
|---|---|---|
| **CDN** | 靠近用戶地理位置 | 静态内容（圖片、CSS、JS、極少變化嘅資源）|
| **應用級 Cache（Redis）** | Database 前 | 讀取密集型查詢，需要毫秒級延遲 |
| **Database Query Cache** | Database 內部 | 頻繁執行嘅相同查詢結果 |

**Cache 策略：**

| 策略 | 寫入時 | 讀取時 | 優點 | 缺點 |
|---|---|---|---|---|
| **Cache-aside** | 直寫 database | 先 cache，miss 再讀 DB | 簡單、常見 | 第一次 miss 要額外讀取 |
| **Write-through** | 同時寫 cache + DB | 直接讀 cache | 讀永遠係最新 | 寫入較慢 |
| **Write-back** | 只寫 cache | cache miss 先讀 DB | 寫入極快 | 宕機可能丢數據 |

**必須掌握概念：**
- **TTL（Time-to-live）** — cache 幾耐後過期
- **Cache invalidation** — 數據變了點清除舊 cache
- **Cache stampede** — 多個 request 同时發現 miss，同時去打 database

### 6. CAP Theorem（一致性 vs 可用性）

> ⚠️ **分區容忍性唔係選擇——喺眞實分佈式系統，網絡分區一定會發生。**
> **所以實際選擇得兩個：要一致性，定可用性？**

| 取向 | 定義 | 例子 |
|---|---|---|
| **强一致性** | 每次讀取都獲得最新寫入 | 轉账後，所有人立即見到最新餘額 |
| **最終一致性** | 系統最終會同步，但暫時可能 stale | 動態 feed、推薦内容 |
| **可用性** | 系統始終響應，即使數據可能唔係最新 | CDN、静态資源服務 |

**關鍵 insight：**
> **唔同模塊可以選不同 CAP 取向。**

```
金融交易、訪問控制、庫存 → 必須强一致性
用戶 content feed、推薦 → 最終一致性完全接受
```

**決策時不要只答「我用最終一致性」，要具體解釋每個操作需要咩保證。**

### 7. SQL vs NoSQL（ACID vs BASE）

> **呢個唔係新舊之爭，係你嘅數據需要咩保證。**

**SQL（ACID）：**

| 特性 | 定義 | 現實比喻 |
|---|---|---|
| **Atomicity** | 事務全有或全無 | 轉账：扣款+入款同時成功或同時失敗 |
| **Consistency** | 永遠喺有效狀態 | 違反規則的數據根本寫唔入 |
| **Isolation** | 並發事務互不干擾 | 兩人同時操作，結果如同依次執行 |
| **Durability** | 提交後永久保存 | 提交後 server 即刻壊，數據唔會lost |

**NoSQL（放鬆 ACID 換取規模）：**
- 放鬆一致性，换取水平擴展能力
- 放棄嚴格 schema，换取靈活性
- BASE：Basically Available, Soft state, Eventual consistency

**決策樹：**
```
你需要强一致性（轉账、庫存、交易）？
├── YES → SQL（PostgreSQL）
└── NO → 你需要水平擴展吗？
    ├── YES → NoSQL（MongoDB / Cassandra / DynamoDB）
    └── NO → 两者都可以，按團隊擅長
```

**實踐：** 大多數 production 系統兩者都用——SQL 做核心業務，NoSQL 做特定場景。

### 8. API Design（契約思維）

> **API 係與每個依賴 client 嘅契約。一旦發布，更改唔係代碼更新，係影響所有下游嘅協調遷移。**

**REST vs GraphQL：**

| | REST | GraphQL |
|---|---|---|
| 適合場景 | 簡單、可緩存、公共 API、移动 client | 多 client 需求不同數據（Web + Mobile 同一後端）|
| 優點 | 簡單、易理解、HTTP cache 友好 | client 精確請求所需，減少 over-fetching |
| 缺點 | 多 endpoint，over-fetching 常見 | 緩存複雜、學習曲線 |

**良好 API 設計原則：**
1. **從第一天起明確版本控制** — `v1` / `v2` 或者 header
2. **圍繞資源設計端點，而非內部操作** — `/users` 而唔係 `/getUsers`
3. **文檔化契約** — 喺别人需要逆向工程之前完成
4. **HTTP method 正確使用** — GET（讀）、POST（創）、PUT（完整更新）、PATCH（部分更新）、DELETE（刪）
5. **Status code 準確** — 200/201/400/401/403/404/500 唔好乱用

### 9. 大規模數據處理（RAG / 10M+ documents）

> ⚠️ **數據處理係 bottleneck——90% effort 放 ingestion，唔係 fancy model。**

**去重方法選擇：**

| 方法 | 準確度 | 速度 | 適用場景 |
|---|---|---|---|
| Exact dedupe（SHA-256） | 100% | 慢 | 對精度要求极高 |
| Fuzzy dedupe（MinHash） | 95%+ | 快 | **Production default** |

**Chunking 原則：**
- 唔好用 fixed-size chunks——用 parent-child / sentence-aware
- 每 chunk 要带 metadata（author / date / language / topic）做 filterable

**Retrieval design（Production-grade）：**
- 純 vector similarity search 唔夠——要 **hybrid**
- **BM25 / keyword**：high precision for exact term
- **Dense vector**：high recall for semantic match
- **Sparse（SPLADE / BGE-M3）**：hybrid signal
- **Re-rank**：cross-encoder / Cohere Rerank，top-100 → top-5 先入 LLM context

**⚠️ 重要提醒：**
- 9 個子系統唔係 sequential pipeline，係 **mesh**
- Generation 必須 **grounded**——答案要 cite source document ID + page
- Refusal：冇足夠 context 時 refuse，唔好 hallucinate

**監控 5 大 metric：** Latency p95 / Retrieval recall / Generation faithfulness / Refusal 率 / Cost-per-query

### 10. 存儲架構（Binary / Object Store / CDN）

> ⚠️ **大文件 / Binary 唔好放 Database——用專門 Object Store。**

**存儲決策原則：**

| 類型 | 存放位置 | 原因 |
|---|---|---|
| **Metadata** | SQL Database | 結構化、queryable、transactional |
| **Binary / 大文件** | Object Store（S3/R2/Azure Blob） | 專門優化、page size 無限、multipart upload |
| **Static / Public files** | CDN | 全球分布、低延遲、cached |
| **敏感文件** | Object Store + Pre-signed URL | 唔經過 API，防止 leakage |

**Pre-signed URL Pattern：**
```
Client → API：「我想上傳文件」
       API → 生成 Pre-signed URL（限時、限操作）
       Client → Object Store：「上傳去呢度」（帶 pre-signed URL）
```
- 上傳時：Client 直接去 Object Store，API 唔係 bottleneck
- 下載時：Client 用 pre-signed URL 直接 download
- 安全：未認證嘅 client 拎唔到 pre-signed URL

**Object Store 優點：** Multipart upload / Pause & resume / 内建 deduplication / File retention policy
**Self-hosted：** Cloudflare R2（egress free）、SeaweedFS

**Async Processing（文件上傳後）：**
- 上傳完成 → Object Store webhook → API → **Message Queue**
- Queue Consumer：Virus scanning / Thumbnail / OCR / Validation

### 11. 認證（AuthN）同授權（AuthZ）

> ⚠️ **永遠分清呢兩個——好多 developer 喺呢度撈亂。**

| | 問 | HTTP Code | 例子 |
|---|---|---|---|
| **Authentication（AuthN）** | Who are you？ | 401 Unauthorized | 你係邊個 |
| **Authorization（AuthZ）** | What can you do？ | 403 Forbidden | 你可以 access 啲乜 |

**順序：** AuthN → AuthZ（AuthZ 假設你已經 AuthN 咗）

**4 個常見 developer confusion（必ず搞清楚）：**

| 誤解 | 真相 |
|---|---|
| 「JWT 係 authentication method」 | JWT 係 **token format** |
| 「Bearer authentication = JWT」 | Bearer 係 **pattern**；JWT 係佢嘅 **implementation** |
| 「OAuth2 係 authentication」 | OAuth2 係 **authorization framework** |
| 「SSO 係 authentication method」 | SSO 係 **UX pattern** |

**Auth Methods 一覽（由舊到强度高）：**
```
Basic Auth（base64）→ Digest（MD5）→ API Key
→ Session + Cookie（stateful，Redis storage）
→ Bearer + JWT（stateless）
→ Access + Refresh Token pair（Modern default）
→ MFA（生產環境強烈建議）
```

**⚠️ 重要提醒：**
- Refresh token **唔准**放 localStorage（XSS 風險）→ 用 HTTP-only cookies
- JWT 係 token format，唔係 method

**OAuth 2 vs OpenID Connect：**

| | 係乜 | 答咩問題 |
|---|---|---|
| **OAuth 2** | Authorization framework | 呢個 app 可以 access 啲乜？ |
| **OpenID Connect** | OAuth 2 + Authentication | user 係邊個？ |

> OAuth 2 只話「app 可以 access 資源」，**唔話你 user 係邊個**。OIDC 加多一層 ID token 解決呢個問題。
> 「Sign in with Google/GitHub/Microsoft」全靠 OIDC。

**SSO 係 UX pattern，唔係 auth method。**
- 底下靠：SAML（enterprise/legacy）或 OIDC（modern）

**Implementation stack recommendation（2026 年參考）：**

| 場景 | 推薦 Stack |
|---|---|
| Public website login | Username/password + MFA + Session cookie（HTTP-only + Secure + SameSite）|
| API（internal/mobile）| JWT access token（15min）+ Refresh token（HTTP-only cookie，7-30 days）|
| 3rd-party integration | OAuth 2 |
| Enterprise SSO | SAML 2.0（legacy）或 OIDC（greenfield）|

**Security Checklist（實作時必check）：**
- [ ] Refresh token 喺 HTTP-only cookies（唔係 localStorage）— 防 XSS
- [ ] Access token short-lived（15 min — 1 hour）
- [ ] HTTPS 全部開啟
- [ ] MFA 喺敏感操作強制開啟
- [ ] Session storage 用 Redis（fast + TTL built-in），唔係 file system
- [ ] JWT verification stateless（每個 request 唔使 DB lookup）
- [ ] API keys 存储時 hash，唔係 plain text
- [ ] Scopes / roles server-side enforce（唔信 client claims）

**Anti-patterns（避免）：**
- JWT 存喺 localStorage — XSS → token 被偷
- 所有 users 用同一個 secret — 泄漏 = 全部泄漏
- Access token 長期有效（30 days）— 泄漏後果嚴重
- Client-side role claims — user 可以自己提升權限

### 12. Agent Memory Architecture（AI Agent 設計診斷）

> ⚠️ **整 AI Agent / Bot 之前，問呢 5 個診斷問題。**

**5 個架構診斷問題：**

| # | 問題 | 為咗 |
|---|---|---|
| 1 | **Working memory 入面有乜？** 呢turn模型眞實見到咩？ | 知道你以為佢有嘅 context 係咪眞實有 |
| 2 | **邊個 past session 重要？** Agent 能否搵到過去嘅 tool calls + outcomes？ | 測試 episodic memory retrieval 質量 |
| 3 | **邊啲 facts 係 current？** 用戶/project facts、偏好、現在狀態點存同更新？ | 測試 semantic memory 新鮮度 + 矛盾處理 |
| 4 | **邊個 workflow 適用？** workflows 係 encoding 做 tools / skills / orchestration code？ | 測試 procedural memory + active recall |
| 5 | **咩應該被遺忘？** 舊狀態點 losing priority？矛盾點處理？邊個擁有事流程式？ | 測試 forgetting strategy + maintenance |

**4 類 Memory Framework（適用於所有 Agent 系統）：**

| 類型 | 定義 | OpenClaw 對應 |
|---|---|---|
| **Working** | 活躍 context window | `session.messages` |
| **Episodic** | 過去事件 + timestamp | `memory/2026-07-XX/*.md` |
| **Semantic** | 長期事實 | `MEMORY.md` |
| **Procedural** | How-to 層 | `skill_workshop` / `AGENTS.md` / `TOOLS.md` |

**4 種 Forgetting Strategy（係 hygiene，唔係 loss）：**
1. **Temporal decay** — 舊記憶降低優先級，除非 pinned / 最近使用 / durable policy
2. **Contradiction handling** — 新事實替換當前；保留舊嘅作為歷史
3. **Compression** — 詳細 sessions → summaries → facts → procedures
4. **Manual curation** — project rules / approval gates 需要 ownership

**Red Flags（狀態分散信號）：**
- Agent「記錯嘢但繼續 confident」（問題根源：agent 唔同意你）
- 净靠 Vector DB → 無法模型狀態轉換
- 舊 procedural memory 驅動代碼編輯，但 project 已經 move on
- 「Perfect recall, no forgetting」→ 每次讀 diary 嚟答問題嘅 agent

### 13. Multi-Agent Systems（多智能體協作）

> ⚠️ **Multi-agent 嘅真正 value 喺約束策略 + workflow，唔喺模型本身嘅智能。**

**Soft Prompt vs Strict Constraint：**

| 寫法 | 性質 | 失敗 mode |
|---|---|---|
| Soft prompt（『請你做 investigate』）| 建議性 | Agent 容易 ignore，hallucination 累積 |
| Strict constraint（step-by-step + black/white list）| 強制性 | 較少 hallucination，但要更多寫約束時間 |

> **寫約束 ≠ 寫 prompt** — Prompt 係 suggestion，Constraint 係 enforcement。

**3 條 Agent 開發核心原則：**

1. **角色級約束（Role-Level Constraint）**
   - 唔係寫 soft prompt，而係寫 **strict 硬約束**
   - 將角色行爲寫死，真正 enforce 行爲邊界

2. **把狐燒開（Disentangle）**
   - Agent 間通訊要 **結構化**、**可審計**
   - 中間狀態 / 結果 / trace 全部 **落文件系統**
   - 唔可以做黑盒

3. **Trace + Review**
   - 每次執行後做 **trace log**
   - 再 **review 改進約束**
   - Prototype 質量先會喺 single-turn 之上 **持續迭代**

**7 階段 Sprint Workflow（J-Star）：**

| Phase | 名稱 | 主要內容 |
|---|---|---|
| 1 | 思考 | 需求分析、problem framing |
| 2 | 規劃 | 6 位專家協作，工件交接鏈 |
| 3 | 開發 | 工程師 + SAMO 評審 |
| 4 | 審查 | 代碼 / 結構 / 測試 review |
| 5 | 測試 | 整合 / e2e |
| 6 | 部署 | Release / 監控 |
| 7 | 反饋 | Trace / 改進 / 下一輪 |

**Phase 2 — 6 位專家角色：**

| 角色 | 職責 |
|---|---|
| Officer Outro | 結構化質問，逼定產品框架 |
| Chief Product Owner | 產品功能篩選 |
| Product Design Documenter | 撰寫設計文檔 |
| Engineering Lead | 技術可行性 / 架構選擇 |
| Dev Lead | 代碼結構 / module 設計 |
| Final Product Designer | 打磨完整思路 |

**3 大底層原則：**

| 原則 | 意思 | 應用場景 |
|---|---|---|
| **Crowding（雙約束）** | Forward + Reverse constraint | 防止 Agent loop / 過度發散 |
| **Tight Constraints** | 特定輸出鎖死 | 敏感任務 / 結構化輸出 |
| **Disentangle** | Output 可追溯，術後 review 可迭代 | Production-grade system |

**Takeaways（記住就得）：**
1. 真正 value 喺 **multi-agent 合作心法**，唔喺 deployment 工具
2. **多 Agent 唔係越多越好** — 規劃階段 6 位，其他階段 2-3 位
3. **Trace 係核心** — 每次跑落文件系統，review 改進約束

---

## 💻 第三階段：語言同框架選擇

> *「語言係工具，唔係身份象徵。」*

### 語言選擇決策矩陣

| 需求 | 推薦語言 | 理由 |
|------|----------|------|
| **快速脚本、automation、整合** | Python / Bash | 生態豐富、rapid prototyping |
| **高性能、並發、reliability** | Go / Rust | 内置 concurrency、編譯强類型 |
| **Web API、快速交付** | Node.js / Python FastAPI | 生態大、開發速度快 |
| **系統編程、memory 管理** | Rust / C | 性能、安全 |
| **任務 critical、fault tolerance** | Elixir / Erlang | Actor model、supervisor tree |
| **膠水語言、一次性工具** | Python / Node.js | 靈活、易部署 |

### 框架選擇原則

```
1. 社群大細 → 大社群 = 更多 Solution、更多坑已踩
2. 維護狀態 → 最近更新時間？活躍度？
3. 學習曲線 → 團隊是否具備相應技能？
4. 部署複雜度 → 部署環境係乜？
5. 長期風險 → 係咪大公司撐緊？有冇 strongly-typed alternatives？
```

### 常見錯誤

- **用新興語言呃 Level** — 新語言能力邊界未確定，踩緊先知
- **為类型安全揀 Rust，但團隊不懂** — 學習曲線係隱藏成本
- **跟風揀 microservices** — 先試 monolith 合理擴展，眞係 scale 到先拆

### Auth Stack 決策矩陣

| 場景 | 建議 | 關鍵考慮 |
|---|---|---|
| 内部工具、一次性 script | Basic Auth / API Key | 必須 HTTPS；API Key leak = 永久 leak |
| 傳統 Web App（多 page）| Session + Cookie + Redis | Stateful，唔適合純 API |
| Modern API / SPA / Mobile | JWT access + refresh token | Stateless；refresh token 要 HTTP-only cookie |
| 第三方服務整合 | OAuth 2 | 只授權 resource access，唔暴露 user credential |
| 「Login with Google/GitHub」| OpenID Connect | OIDC = OAuth 2 + AuthN |
| 企業内部、多系統 | SSO + SAML 或 OIDC | 先揀 identity protocol |
| 高安全性需求 | MFA 強制開啟 | Password + TOTP/SMS |

---

## 🔄 第四階段：操作同生命周期

> *「代碼寫完係部署，部署完係維護。」*

### 部署策略決策

| 場景 | 部署方式 |
|------|----------|
| 快速驗證、實驗 | Local / Docker |
| 小規模、長期運行 | VM + 系統d |
| 中規模、需 auto-scale | Kubernetes / Docker Swarm |
| 大規模、需要零 downtime | Blue-Green / Canary |

### 備份原則

```
1. 數據係核心 → 任何改動前先確認 backup 機制存在
2. 可恢復性係目標 → backup 幾分鐘前的狀態？唔係幾日前？
3. 測試恢復流程 → 唔係「備咗」，係「恢復得」
4. 備份隔離 → backup 同原件唔可以擺同一個 storage
```

### 監控清單

- [ ] **健康檢查（Health Check）** — 系統係咪存活？
- [ ] **Metrics** — key metrics 有冇被人看住？
- [ ] **Logs** — 錯誤有冇被記錄？有冇人去睇？
- [ ] **Alert** — 邊個喺深夜收到 alert？有冇 set channel？
- [ ] **On-call rotation** — 壊咗邊個 decision？幾耐內要回應？

---

## 🧠 第五階段：知識累積同分類

> *「一次失敗係 lesson，多次失敗係 pattern。」*

### 知識分類框架

```
Layer 1｜Tool Playbook（工具使用心得）
  → 邊個 tool 喺咩場景掂、成功率幾多、常见问题

Layer 2｜System Lessons（系統性錯誤 lesson）
  → 根因分析 + 防止再犯方案

Layer 3｜Design Decisions（架構决策記錄）
  → 點解揀呢個方案？放棄咗邊個替代方案？
```

### Decision Log 格式

```
## [日期] 决策：XXXXXXXX

**問題：** XXXXXXXXX
**考慮過嘅方案：**
  - A：XXXXXXXX（放棄原因：XXXX）
  - B：XXXXXXXX（放棄原因：XXXX）
**選擇：** B
**理由：** XXXXXXXX
**驗證日期：** XXXX-XX-XX
```

### 知識沉積原則

> **增量追加，唔整體重寫**
> 每個項目做完，問：「我學到咩？」→ 追加一行到相應嘅 playbook。

---

## ⚠️ 第六階段：常見陷阱同反模式

### 架構陷阱

| 陷阱 | 描述 | 解法 |
|------|------|------|
| **Over-engineering** | 未確定需求就整架構 | YAGNI |
| **God Object** | 一個 module 做晒所有嘢 | Single Responsibility |
| **Shared Database** | 多個 service 直接讀同一個 DB | 每個 service 自己嘅 DB |
| **Synchronous everywhere** | 所有嘢都係同步，block晒 | Async where appropriate |
| **Premature optimization** | 未 profiling 就優化 | Make it work → right → fast |

### 團隊陷阱

| 陷阱 | 描述 | 解法 |
|------|------|------|
| **Not Invented Here** | 為咗自己整唔用 third-party | Evaluate existing solutions first |
| **Bus factor = 1** | 得一個人知點搞 | Documentation + knowledge sharing |
| **Analysis paralysis** | 过度分析，唔郁 | Set timeboxes for decisions |
| **Hero culture** | 靠一個人深夜 on-call | On-call rotation + runbooks |

---

## 🔧 第七階段：維護 SOP 本身

| 頻率 | 内容 |
|------|------|
| **每次用完** | 追加 lesson 到相應 playbook |
| **每週** | Quick scan 有冇矛盾/過時 |
| **每項目完成** | 寫 decision log + 更新 playbook |
| **每季** | Full review——删除已過時、合併重複 |

### 觸發即時更新嘅情况
- 新 tool 發現穩定 pattern
- 新語言/框架决案
- 踩坑——無論大小
- 架構變動

---

## 📋 SOP 使用流程圖

```
開始新 Project
    │
    ▼
Phase 1 → 確認問題（5 條必答）
Phase 2 → 架構考慮（12 個 section 逐一 check）
Phase 3 → 語言/框架選擇
Phase 4 → 操作生命週期
Phase 5 → 執行 + 記錄
```

---

*Last updated: 2026-07-12*
*資料來源：YouTube system design 教學 + 知識庫熔爐 distillation + OpenClaw 自身架構經驗*
*用途：Software / Application 設計思考框架，非 Ops 流程標準*
