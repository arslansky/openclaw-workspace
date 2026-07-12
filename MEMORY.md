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
| OVR-001 | minimax/image-01 | gpt-image-2 via script | ✅ active |
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

*最後更新：2026-07-12 · 精簡版，reference 已搬出*