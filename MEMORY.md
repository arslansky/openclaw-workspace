# MEMORY.md｜OpenClaw 持久記憶

> 每次 session 讀呢個文件，作為長期記憶參考。
> 更新時：刪除過時、合併重複、保持簡潔。

---

## 用戶資料

- **Name:** Arslan
- **What to call them:** Arslan
- **Username:** @Arslansky
- **Telegram ID:** 160408068
- **Timezone:** GMT+8

---

## 🖼️ 生圖（Evie 角色）

**⚠️ 每次生圖必須行 `bash scripts/smart_image_gen.sh`，唔准用 `image_generate` tool**

**角色設定（固定）：**
- 亞洲女性，約16歲，心形面，精緻瓷肌，透紅
- 短黑棕色頭髮，微卷髮尾
- 柔和杏仁眼（Soft Almond，A2 眼型），自然雙眼皮
- 眼神：柔中堅定，淡妝，粉色腮紅

**Prompt（參考）：**
```
Asian woman portrait, luminous porcelain skin, MEDIUM black wet-look hair with slight outward curved tips, fox-shaped face with narrow chin, soft almond-shaped eyes with slight upward angle and warm sparkle, gentle innocent gaze, straight flat eyebrows with slight lift at tail, soft sweet gentle smile lips, short soft cute nose with rounded tip, light natural makeup with pink blush. White dry athletic top, sports field background, soft warm cinematic lighting, front facing, no text, no watermark
```

**Cyberpunk 白戰鬥服（無武器）：** 白色未來感機甲套裝，發光霓虹飾邊，技術戰鬥盔甲，`no weapons`

**Reference 圖：** `~/.openclaw/media/inbound/71e567ae-4070-47db-a4de-0f7a9766d117.jpg`

---

## 🤖 Telegram Bots

| Account | Bot ID | Username | 用途 |
|---|---|---|---|
| `arslansky` | `8688406477` | @arslanskybot | 主要私人對話 |
| `janzaibot` | `8302835438` | @Janzaibot | Big VM |
| `know2learn` | `8401590390` | @Know2learn_bot | 知識庫熔爐（inbox capture）|
| `zo` | `8205470881` | @ZO_001_bot | Last Guardian 2（ZO Computer VM）|
| `ds` | `8523709022` | @DS_26bot | Deepseekbot |

### Group ID

| Group ID | Name | 服務 Bot |
|---|---|---|
| `-1003897497805` | Kimi 綜合工作區 | @arslanskybot |
| `-1003859753438` | GPT-Image-2 Creation Bot | @arslanskybot |
| `-5530265702` | English Learning | @arslanskybot |
| `-1003924885824` | 知庫群組（forum）| @arslanskybot（⚠️ forum ingress 壞，待修）|

### Bot Debug

- `gateway` 重啟後有時 janzaibot/know2learn 甩線 → restart 解決
- **know2learn forum ingress 問題：** Bot `has_topics_enabled: false`，需 `/deletebot` + `/newbot` 重建
- Debug：`openclaw gateway call health` | `curl http://127.0.0.1:18789/health`

---

## 🗂️ 知識庫 Vault

- **位置：** `~/obsidian/knowledge/`
- **know2learn bot** 所有對話 → 自動入 inbox `00-Inbox/`
- **流程：** inbox → 消化 → atomic notes → permanent notes
- **每週六 10:00（GMT+8）** → cron remind review inbox

### inbox 指令
```
inbox: [任何嘢]
```
一句都好，我幫你寫入 inbox。

---

## 🛠️ Scripts 目錄

**主目錄：** `~/.openclaw/workspace/scripts/`
**Toolbox（備份）：** `~/toolbox_repo/openclaw/`（每週自動 sync）

| Script | 用途 |
|---|---|
| `smart_image_gen.sh` | 生圖（gpt-image-2）|
| `gen_pdf.py` | PDF 生成（中文友好）|
| `news_fetch.sh` / `news_summary.sh` | 新聞抓取 / 總結 |
| `weekly-skills-backup.sh` | Skills 備份 |
| `img2img.sh` | 圖生圖 |
| `organize_images.sh` | 圖片整理 |

---

## 🖥️ VMs

| VM | Host | User | Port | 狀態 |
|---|---|---|---|---|
| **Oracle** | `161.118.247.199` | `opc` | 22 | ✅ |
| **Zeabur**（Gateway）| `43.156.247.30` | `ubuntu` | 22 | ✅ |
| **ZO** | `ts8.zocomputer.io`（`150.136.143.138`）| `root` | 10661 | ❌ port 10661 connection refused |

### SSH
```bash
# Oracle
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ~/.ssh/zeabur_key opc@161.118.247.199
# ZO
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p 10661 -i ~/.ssh/zeabur_key root@ts8.zocomputer.io
```

---

## 🔄 ACE Feedback Loop

**每次 script/tool 執行完，寫 log：**
```bash
echo '{"script": "...", "task": "...", "success": true, "duration_sec": N, "note": "..."}' >> memory/tool-log.jsonl
```
- 禁止空白——起碼要有 task description
- 每週六 inbox review → 同步更新 `memory/tool-playbook.md`

---

## 📋 TRAP 雙層規劃

**所有複雜任務** → `memory/tasks/active/<task-id>/`

```
memory/tasks/
├── _registry.md          # 任務總表
├── active/<task-id>/
│   ├── _plan.md         # Abstract Plan
│   └── _subtasks.md    # Field-mapped subtasks
└── completed/          # 完成歸檔
```

**失敗模式：** myopic | plan_drift | short_term_bias | other

---

## 🔬 Harness Engineering 研究

**主文件：** `~/obsidian/knowledge/02-Permanent/harness-engineering.md`

持續研究 ACE / SICA / TRAP / MCE / Meta-Harness 框架。
最新：✅ ACE + SICA + TRAP 論文原文已讀。

---

## 📊 AI 新聞顧問框架

觸發指令：「顧問模式分析呢篇」

9步框架（詳見 harness-engineering.md 或 long-term notes）。

---

## ⚙️ Custom Overrides

| ID | 項目 | Config vs Actual | 狀態 |
|---|---|---|---|
| OVR-001 | imageModel.primary | minimax/image-01 → gpt-image-2 via script | ✅ active |
| OVR-002 | Vision Model | kimi-k2.6 dead → **kimi-code/k2p6**（2026-07-11）| ✅ resolved |
| OVR-003 | DeepSeek Failover | yuanyuaicloud + ttk 雙 provider | ✅ active |

---

## 📝 System Lessons

**Token 驗證：** 省略 token（如 `820547…xmgE`）係俾人睇嘅，唔係俾 API 用。永遠從 `openclaw.json` 拎完整 token。

**詳見：** `memory/SYSTEM-LESSONS.md`

---

*最後更新：2026-07-11*
