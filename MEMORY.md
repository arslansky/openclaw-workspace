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
| OVR-001 | minimax/image-01 | **gpt-image-2 via Zhi API** via `scripts/smart_image_gen.py` (Aetheracode primary → Zhi fallback) | ✅ active |
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

## Promoted From Short-Term Memory (2026-07-26)

<!-- openclaw-memory-promotion:memory:memory/2026-07-03.md:1:27 -->
- # 2026-07-03 ## arslanskybot 無反應 - Debug 全紀錄 ### 問題 arslanskybot 喺 Telegram groups 完全收唔到 messages（包括 @mention），但 direct DM 正常。 ### 根因 `channels.telegram.accounts.default` 同 `accounts.arslansky` 用咗**同一段 bot token**。 OpenClaw Telegram plugin 初始化時 detect 到 duplicate token → `default` account fail → 成個 Telegram channel 變 `"not configured"` → 所有 incoming updates 唔被分發。 ### 修復 刪除 `accounts.default` block from `openclaw.json`，然後 restart gateway。 ### Debug 流程（日後跟住做） 1. `openclaw gateway call health` → 睇 `configured`、`lastError` 2. 如果有 duplicate token error → `cat openclaw.json | jq '.channels.telegram.accounts'` 3.... [score=1.000 recalls=26 avg=1.000 source=memory/2026-07-03.md:1-27]
<!-- openclaw-memory-promotion:memory:memory/2026-07-11.md:94:137 -->
- ✅ ZO VM：**port 10661 connection refused**（blocker） - ✅ openclaw-workspace repo：404 已修復，backup working - ✅ toolbox_repo：sync ok - ✅ Bots：全部 5 個 bot token 確認有效（ZO_001_bot / DS_26bot / Janzaibot / Know2learn / arslanskybot） ### Phase 2 進行中（Fix Blockers） | Item | Status | |---|---| | weekly-skills-backup.sh 同步 | ✅ 已修復（已 commit toolbox_repo）| | ZO VM port 問題 | 🔴 blocker，待聯繫 ZO | | janzaibot / ds 用途 | 🟡 pending | | know2learn forum ingress | 🟡 pending | ### Blocker Summary - ZO VM 已壞（port 10661 connection refused），用戶需要確認 VM 狀態 - 2 個新 bot（zo + ds）用途未知，需確認 --- ## System Lesson 建立（2026-07-11） ### 錯誤：Telegram Bot Token 驗證失敗 - 我用咗省略格式... [score=1.000 recalls=20 avg=1.000 source=memory/2026-07-11.md:94-137]
<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-11.md:1:26 -->
- # 2026-07-11 操作日誌 > 記錄所有操作動作（刪除、搬遷、改 config、加新 file、合併）。 > 只記錄做過咩，唔記錄內容。格式：`HH:MM｜動作分類 - 詳情` --- ## 22:00-23:00｜系統整理（guideline + override） - 建立: 7 份知識庫文件（guideline-bootstrap / guideline-custom-override / sop-master / report-file-upload / report-model-usage / model-registry / overrides.json） - 改: openclaw.json → 加 kimi-code/k2p6 做 vision model（backup: openclaw.json.bak.20260711） - 改: overrides.json → OVR-002 deprecated（vision fix）, OVR-004 added（failover chain suggestion） - 改: MEMORY.md → 加 Custom Overrides section - 改: SOP Master → v0.1→v0.2→v0.3 ## 01:46-01:48｜Workspace 清理 - 刪: SOUL.md.bak / AGENTS.md.bak / USER.md.bak /... [score=1.000 recalls=16 avg=1.000 source=memory/ops/2026-07-11.md:1-26]
<!-- openclaw-memory-promotion:memory:memory/2026-07-11.md:27:67 -->
- ✅ 與 vault 其他 notes 建立 cross-links（deepspark、three-layer-attention、insight-007） - ✅ 主 note 加入關鍵詞口徑，方便日後搜索 ### 已整合資料 - YouTube z_F0z7wF5XU（Lilian Weng 博客解讀）✅ - 系統性搜索 vault 其他 notes，確認係此主題新增嘅源 --- ## SICA + TRAP 深度研究（2026-07-11） ### 完成項目 - ✅ Lilian Weng 博客原文（2026-07-04）已讀 - ✅ SICA 論文（arXiv:2504.15228）已讀核心內容 - ✅ TRAP 詳細機制已理解並寫入 harness-engineering.md - ✅ PDF `SICA-TRAP-Guide.pdf` 已發送到 Telegram - ✅ Atomic note `note-SICA-TRAP-2026-07-11.md` 已創建 ### SICA 核心要點 - reasoning_agent（診斷）+ coding_agent（edit 自己）兩層 - SWE-bench Verified：17% → **53%**（+36pp） - 靠 LLM-driven code edits，唔靠 gradient learning ### TRAP 核心要點 - 雙層規劃：Abstracted Plan +... [score=1.000 recalls=7 avg=1.000 source=memory/2026-07-11.md:27-56]
<!-- openclaw-memory-promotion:memory:memory/2026-07-02.md:1:28 -->
- # 2026-07-02 Daily Notes（已過時，部分內容已遷移至 SYSTEM-LESSONS.md） > ⚠️ 此文件已過時。重要 lesson 已遷移至 `memory/SYSTEM-LESSONS.md`。 > SSH key direction lesson → SYSTEM-LESSONS.md ✅ > Bot status → MEMORY.md ✅ > SSH connections → MEMORY.md ✅ ## SSH Key Path Issue (Important) **Problem:** Kimi Boy (group bot) was using wrong SSH key path when connecting to Oracle VM from Zeabur VM.... [score=0.963 recalls=21 avg=1.000 source=memory/2026-07-02.md:1-28]
<!-- openclaw-memory-promotion:memory:memory/2026-07-16.md:1:20 -->
- # 2026-07-16 Daily Notes (Session Summary) ## Active Memory & Dreaming 設定 - 將 memorySearch provider 由 openai 改為 none（純 keyword FTS），因 OpenAI API key 未配對到 agent auth store - 啟用咗 Active Memory plugin（arslansky-agent），每次 reply 前自動 recall 記憶 - 啟用咗 Dreaming（memory-core），排程每日凌晨 3am - 試行 Dreaming sweep，但短期記憶庫暫時為空 ## 問題 - memory_search 因 embedding provider 唔匹配而 paused，已用 `openclaw memory index --force` 同 config 改 provider=none 解決 2026-07-16 00:19-00:42: 整咗三樣野 1) Fix memory_search: 原因係 OpenAI embedding provider 冇 API key 喺 agent auth store，用 Plan B 改 provider=none（純 keyword FTS），rebuild index 成功 2) 開 Active Memory: 加 plugin entry +... [score=0.931 recalls=7 avg=1.000 source=memory/2026-07-16.md:1-20]
<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-16.md:1:23 -->
- 00:29｜Gateway restart - Set memorySearch.provider to none 00:33｜Config change - Added active-memory plugin entry with enabled:true 00:33｜Config change - Added dreaming.enabled:true to memory-core 00:33｜Config change - Added active-memory to plugins.allow list 00:33｜Gateway restart - Active Memory + Dreaming enabled ## 04:05｜Snapshot Diff（自動 detect） **新增檔案：** - /home/ubuntu/.openclaw/workspace/ds-agent/memory/.dreams/events.jsonl - /home/ubuntu/.openclaw/workspace/memory/2026-07-16-dreaming-test.md - /home/ubuntu/.openclaw/workspace/memory/2026-07-16.md - /home/ubuntu/.openclaw/workspace/memory/.dreams/events.jsonl -... [score=0.915 recalls=6 avg=1.000 source=memory/ops/2026-07-16.md:1-23]
<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-12.md:53:82 -->
- Pre-signed URL pattern - Object Store 優點 + self-hosted 選項 - Async processing via queue - 完整 File Upload Service 架構圖 ## 13:22｜全部整合更新 sop-master.md - 發現: 三份高價值舊文件 - para/resources/.../系統設計_6個核心概念.md（Maddie, 6-core-concepts） - minimax-agent/memory/.../auth.md（implementation cheat sheet） - minimax-agent/memory/.../system-design.md（Agent Memory Architecture） - 更新: sop-master.md（全面重寫，14494 bytes） - 新增 Phase 2 Section 4: Statelessness - 新增 Phase 2 Section 5: Caching（CDN/Redis/Query cache、cache策略） - 新增 Phase 2 Section 6: CAP Theorem（一致性 vs 可用性） - 新增 Phase 2 Section 7: SQL vs NoSQL（ACID vs BASE） - 新增 Phase 2 Section 8: API Design（REST vs... [score=0.899 recalls=5 avg=1.000 source=memory/ops/2026-07-12.md:53-82]
<!-- openclaw-memory-promotion:memory:memory/2026-07-11.md:129:140 -->
- Scripts 正常，暫時性 model 響應慢，唔使擔心 - toolbox-daily-sync + workspace-daily-backup 均有重試機制 ## PDF 閱讀障礙解決 - PDF tool 需要 pymupdf，但系統冇安裝 - 安裝方法：`pip3 install --break-system-packages pymupdf` - 成功讀取 YouTube 總結 PDF（z_F0z7wF5XU） ## 影片來源 - z_F0z7wF5XU：最佳拍檔·大飛，解讀 Lilian Weng《Recursive Self-Improvement》博客 [score=0.896 recalls=5 avg=1.000 source=memory/2026-07-11.md:129-140]
<!-- openclaw-memory-promotion:memory:memory/ops/2026-07-11.md:22:33 -->
- 搬: loop-engineering-summary.pdf / unlimited_ocr_summary.pdf → sources/pdf/ - 搬: threads_post.png → media/outbound/ - 合併: VM_CONNECTION_MANUAL.txt 刪（同 .md 重複）、REVIEW_CHECKLIST.md 搬入 AGENTS.md - 搬: review_hook.py → scripts/ - 分類: 7 份 inbox → 3 份 guideline 去 03-Areas/、3 份 report 去 04-Resources/、overrides.json 去 workspace root - 刪: ds-agent/BOOTSTRAP.md / IDENTITY.md / USER.md（空白 template，未填） ## 01:54-01:55｜建立操作日誌系統 - 建立: memory/ops/ folder + 此日誌檔案 - 改: SOUL.md + AGENTS.md → 加入 ops log 規則 - 改: HEARTBEAT.md → 加入 safety net check（檢測 ops/ 有冇今日 file） [score=0.882 recalls=4 avg=1.000 source=memory/ops/2026-07-11.md:22-33]
