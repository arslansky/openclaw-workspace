# MEMORY.md｜OpenClaw 持久記憶

> 每次 session 自動 load，只保留 startup 需要嘅規則同設定。
> Reference 已搬去 `sources/reference/`，用時先讀。

---

## 👤 用戶

- **Name:** Arslan
- **Telegram:** @Arslansky（160408068）
- **Timezone:** Asia/Shanghai（GMT+8）

---

## 🖼️ 生圖規則

**⚠️ 必須行 `bash scripts/smart_image_gen.sh`，唔准用 `image_generate` tool**

**Evie 角色設定（固定）：**
- 亞洲女性，約16歲，心形面，精緻瓷肌
- 短黑棕色頭髮，微卷髮尾
- 柔和杏仁眼（A2 眼型），自然雙眼皮，柔中堅定眼神
- 淡妝，粉色腮紅
- **必須加 tag：** `no weapons`

**Reference 圖：** `media/inbound/71e567ae-4070-47db-a4de-0f7a9766d117.jpg`

---

## ⚙️ Custom Overrides

| ID | Config | Actual | Status |
|----|--------|--------|--------|
| OVR-001 | minimax/image-01 | **gpt-image-2 via Zhi API only** via `scripts/smart_image_gen.py` (Aetheracode removed 2026-07-28) | ✅ active |
| OVR-002 | kimi-k2.6 (dead) | kimi-code/k2p6（2026-07-11 resolved）| ✅ resolved |
| OVR-003 | 單 provider | yuanyuaicloud + ttk 雙 provider | ✅ active |

**詳見：** `overrides.json`

---

## 🔄 ACE Feedback Loop

**每個 script/tool 執行完，寫 log：**
```bash
echo '{"script": "...", "task": "...", "success": true, "duration_sec": N, "note": "..."}' >> memory/tool-log.jsonl
```
- 禁止空白，起碼要有 task description
- 每週六 inbox review → 更新 `memory/tool-playbook.md`

---

## 📋 TRAP 雙層規劃

**複雜任務 → `memory/tasks/active/<task-id>/`**

```
memory/tasks/
├── _registry.md        # 任務總表
├── active/<task-id>/   # _plan.md + _subtasks.md
└── completed/          # 完成歸檔
```

**失敗模式：** myopic | plan_drift | short_term_bias | other

---

## 📝 System Lessons

**Token 驗證：** 省略 token（如 `820547…xmgE`）係俾人睇嘅，唔係俾 API 用。
永遠從 `openclaw.json` 拎完整 token。
詳見：`memory/SYSTEM-LESSONS.md`

---

## 📚 English Learning - Vocab Check SOP

**Trigger：** 用戶發 "vocab check" + 生字列表

**Output Format：**
```
WORD /pronunciation/ · part of speech · **中文粗體**
變化： verb形式（如適用）
→ 例句①（真實語境）：English
  （中文）
→ 例句②：English generic
  （中文）
配合： collocations
同義： synonyms（最強→最弱）
⚠️ 注意： usage注意 / 陷阱 / 區分
---
```

**規則：**
- 例句① 必須用戶提供嘅真實語境，② 係 generic
- 同義詞強度排序
- 標明 register（formal/informal/slang）及及物/不及物
- 每字後加 `---` 分隔

**Template source：** `memory/2026-07-14.md`

---

## 📎 Reference Links（用時先讀）

| 主題 | 位置 |
|------|------|
| Telegram Bots + Groups | `sources/reference/telegram-bots.md` |
| VMs + SSH | `sources/reference/vm-connections.md` |
| Knowledge Vault 結構 | `memory/` 或 project 內 — 按主題分類
| Scripts 目錄 | `sources/reference/scripts-index.md` |
| Harness Engineering 研究 | `02-Permanent/harness-engineering.md` |
| English Learning Vocabulary | `05-English/02-Language-Lab/vocabulary/` |
| AI 新聞顧問框架 | `03-Areas/`（inbox 待分類）|

---

## 🧠 Active Memory & Dreaming（2026-07-16）

- **Active Memory**：`memorySearch` provider 改為 `none`（pure keyword FTS），避免 OpenAI embedding key 不匹配問題；`memory index --force` 重建成功
- **Dreaming**：memory-core 啟用 `dreaming.enabled=true`，每日 3am 自動 consolidation；短期記憶庫初次運行中
- **相關教訓**：memory search 因 embedding provider mismatch 而 paused → 用 `provider=none` + `openclaw memory index --force` 解決

---

*最後更新：2026-07-16 · Active Memory + Dreaming 設定新增*

## Promoted From Short-Term Memory (2026-07-27)

<!-- openclaw-memory-promotion:memory:memory/2026-07-11.md:61:101 -->
- ✅ `note-ACE-OpenClaw-落地應用-2026-07-11.md`（application note） - ✅ PDF 發送到 Telegram（`ACE-Guide.pdf`） - ✅ `memory/tool-playbook.md` — Level 1 MVP tool playbook（ACE 風格） ### 三個落地層次 1. **Level 1（立即）** — `memory/tool-playbook.md` ✅ 2. **Level 2（短期）** — script 加 `--log`，日誌寫入 `tool-log.jsonl` 3. **Level 3（長期）** — 自動化 Reflector + Curator 循環 --- ## TRAP 雙層規劃結構建立（2026-07-11） ### 完成項目 - ✅ `memory/tasks/_registry.md` — 任務總表 - ✅ `memory/tasks/active/_TASKID_/_plan.md` — Abstract Plan 模板 - ✅ `memory/tasks/active/_TASKID_/_subtasks.md` — Field-mapped subtasks 模板 - ✅ `memory/tasks/completed/_TASKID_.md` — 完成歸檔模板 - ✅ MEMORY.md 更新，加入 TRAP + SICA 落地應用章節... [score=0.845 recalls=4 avg=1.000 source=memory/2026-07-11.md:61-101]
<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-12.md:24:61 -->
- 更新: MEMORY.md 移除失效既 knowledge vault link ## 13:05｜Inbox 處理 + SOP 更新 - 收到: 知識庫熔爐 forwarded authentication PDF（YouTube iX8g4LqF8p8 21min） - 讀取: minimax-agent/memory/2026-07-12/yt-transcripts/iX8g4LqF8p8/iX8g4LqF8p8.summary.zh-Hans.md - 寫入: memory/inbox-2026-07-12.md（raw inbox） - 更新: sop-master.md - Phase 2 新增：AuthN vs AuthZ 决策樹 + 7種 Auth Methods + JWT/OAuth2/OIDC/SSO 详解 - Phase 3 新增：Auth Stack 決策矩陣 ## 13:07｜第二份 inbox 處理 - 收到: RAG × 私有資料庫 PDF（YouTube NQZqET-jjws，14:34） - 寫入: memory/inbox-2026-07-12.md（#002） - 更新: sop-master.md → Phase 2 新增「大規模數據處理」section - 去重方法選擇、去重/SHA/MinHash - Chunking 原則 - Hybrid retrieval + re-rank -... [score=0.804 recalls=3 avg=1.000 source=memory/ops/2026-07-12.md:24-61]

## Promoted From Short-Term Memory (2026-07-29)

<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-20.md:1:22 -->
- ## 04:05｜Snapshot Diff（自動 detect） **新增檔案：** - /home/ubuntu/.openclaw/workspace/ds-agent/IDENTITY.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/2026-07-16.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/2026-07-17.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/2026-07-18.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/2026-07-19.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/ops/2026-07-19.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/ops/2026-07-19-part2.md - /home/ubuntu/.openclaw/workspace/ds-agent/memory/ops/2026-07-19-part3.md -... [score=0.873 recalls=3 avg=1.000 source=memory/ops/2026-07-20.md:1-22]

## Promoted From Short-Term Memory (2026-08-14)

<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-28.md:19:40 -->
- /home/ubuntu/.openclaw/workspace/minimax-agent/memory/dreaming/rem/2026-07-28.md - /home/ubuntu/.openclaw/workspace/minimax-agent/memory/.dreams/session-corpus/2026-07-27.txt > ⚠️ 以上係 snapshot diff 自動 detect 嘅變化。如果有操作但 ops log 冇記錄，請補寫。 ## 22:43｜Image Folder Reorganization + Vision Model Setup **操作：** 1. 舊圖（181張）集中到 `images/archive/legacy/` 2. 建立 folder structure：`evie/{lolita,gothic,portrait}`, `characters`, `reference`, `experiments` 3. 清空 21 個空 date folders 4.... [score=0.808 recalls=3 avg=1.000 source=memory/ops/2026-07-28.md:19-40]
