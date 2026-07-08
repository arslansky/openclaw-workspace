# MEMORY.md

## 圖片生成

- **所有生圖** → 用 `bash scripts/smart_image_gen.sh`
- **Model:** Aetheracode gpt-image-2（直接 call API，唔經 OpenClaw image provider）
- **Script 位置:** `~/.openclaw/workspace/scripts/smart_image_gen.sh`
- **Usage:** `bash scripts/smart_image_gen.sh "<prompt>" [size] [quality] [model]`
- **Example:** `bash scripts/smart_image_gen.sh "a cute robot" "1024x1024" "high" "gpt-image-2"`

### 常用 Prompt（2026-07-05）

**Evie 角色設定：**
- 亞洲女性，約16歲
- 精緻瓷肌，透紅
- 短黑棕色頭髮，微卷髮尾
- **心形面**（非鵝蛋面），五官精緻
- 柔和杏仁眼，自然雙眼皮
- 眼神：柔中堅定（soft but firm gaze）
- 淡妝，粉色腮紅

**Evie cyberpunk 白戰鬥服（無武器）prompt（英文原版）：**
```
Asian woman portrait, delicate porcelain skin, short black-brown hair with subtle waves at ends, small sharp delicate heart-shaped face, gentle almond eyes with natural double eyelids, soft but firm gaze, light natural makeup with pink blush. Cyberpunk warrior in white futuristic combat suit with glowing neon cyan accents, tech-wear battle armor, sleek white LED trim, combat gloves, holographic HUD elements, battle-ready pose, dark moody lighting with cyan rim light, futuristic sci-fi aesthetic, highly detailed, cinematic, no weapons
```

**Evie cyberpunk 白戰鬥服（無武器）prompt（中文版）：**
```
寫真照片，亞洲女性，精緻瓷肌，短黑棕色頭髮，微卷髮尾，心形面，五官精緻，柔和杏仁眼，自然雙眼皮，眼神柔中堅定，淡妝，粉色腮紅。科幻戰鬥服，白色未來感機甲套裝，發光霓虹飾邊，技術戰鬥盔甲，光滑LED線條，戰鬥手套，全息HUD元素，戰鬥姿勢，暗色情緒照明，霓虹邊緣光暈，未來科幻美學，高品質，電影感
```

**人物參考圖：** `~/.openclaw/workspace/media/inbound/b3cf4f8a-7917-4516-9833-6ba74f58c220.jpg`

## Telegram Bot 設定（2026-07-05 更新）

### Bot ID 對照表

| Account | Bot ID | Username | Display Name |
|---|---|---|---|
| `arslansky` | `8688406477` | @arslanskybot | Kimi Boy |
| `janzaibot` | `8302835438` | @Janzaibot | Big VM |
| `know2learn` | `8401590390` | @Know2learn_bot | 知識庫熔爐 |
| `zo` | **待加入** | **待加入** | **ZO Computer Bot** |

### 用途
- `arslansky` — 主要私人對話
- `janzaibot` — 用途待確認
- `know2learn` — **知識庫 bot**，inbox capture + 知識沉澱
- `zo` — **ZO Computer bot**（新開，尚未配置）

### Group ID 對照

| Group ID | Name | 服務 Bot |
|---|---|---|
| `-1003897497805` | Kimi 綜合工作區（forum topic:1）| @arslanskybot |
| `-1003859753438` | GPT-Image-2 Creation Bot | @arslanskybot |
| `-5530265702` | English Learning | @arslanskybot |
| `-1003924885824` | 知庫群組（forum）| @arslanskybot（know2learn group ingress 已壞）|

## 知識庫 Vault（2026-07-05）

- **位置：** `~/obsidian/knowledge/`
- **呢個 bot（know2learn）所有對話內容** → 預設自動入 inbox `~/obsidian/knowledge/00-Inbox/`
- **流程：** inbox → 我哋一齊消化 → atomic notes → permanent notes
- **Workflow 規則：** `~/obsidian/knowledge/00-Inbox/WORKFLOW.md`
- **每週六 10 點（GMT+8）** → cron remind review inbox

### inbox 指令
任何時侯喺呢個 bot 話我知就得：
```
inbox: [任何嘢]
```
你唔使寫完整，一句都好，我幫你寫入 inbox。

- **Config位置：** `~/.openclaw/openclaw.json`
- 三個account完全分開，唔存在token衝突
- 所有group設定 `requireMention: false`（唔使@都會回）
- arslansky嘅 `richMessages: false`

### 常見問題
- gateway重啟後有時janzaibot/know2learn會甩線，試restart解決
- **know2learn group ingress 已壞**：Bot ID `8401590390` `has_topics_enabled: false`，Telegram 唔 delivery forum group messages。需 `/deletebot` + `/newbot` 重建。
- **Debug工具：**
  - `openclaw gateway call health` → 查看各account connected狀態
  - `curl http://127.0.0.1:18789/health` → gateway是否活着

## 🖼️ 生圖觸發規則（2026-07-07 追加）

**⚠️ 每次生圖必須行呢個流程，唔准跳過：**

1. **嚴格跟流程：生圖請求 → `bash scripts/smart_image_gen.sh`**
2. **唔准用 `image_generate` tool** —— 呢個係 miss trigger 根源，會默認用 minimax
3. **Prompt 尾加 tag**：`no weapons`（MEMO：之前有次出錯漏咗武器）
4. **Scripts 位置：** `~/.openclaw/workspace/scripts/smart_image_gen.sh`
5. **模型：** `gpt-image-2`（固定，唔准改，除非 script 本身 fail）
6. **Output：** `~/.openclaw/workspace/images/YYYY-MM-DD/`

**觸發關鍵詞（任何一個都觸發）：**
- 生圖 / generate image / create image / 画
- image prompt / 描述角色
- 再生成 / regenerate

**出事紀錄（2026-07-07）：** 第一次 request 我用咗 `image_generate` tool 導致用咗 minimax model，user 提醒先知用錯。根因係 native tool 搶佔咗 workflow。

## Image Model 問題（2026-07-05）

- **zhi-api/kimi-k2.6 已死**（502 Bad Gateway）
- Group `-1003859753438`（GPT-Image-2 Creation Bot）由 arslansky bot 服務，生圖功能已壞
- 需要盡快更換可用嘅 image model provider

## English Learning Group（2026-07-05）

- **Group Name:** English Learning
- **Group ID:** `-5530265702`
- **用途:** 英文學習、英文寫作為主
- **Bot:** arslansky（@arslanskybot）

## 三台 VM（2026-07-05 更新）

| VM | Host | User | Port | Auth | 狀態 |
|---|---|---|---|---|---|
| **Oracle VM** | `161.118.247.199` | `opc` | 22 | `~/.ssh/zeabur_key` | ✅ |
| **Zeabur VM** | `43.156.247.30` | `ubuntu` | 22 | Password / SSH key | ✅（呢部係我哋目前嘅 Gateway）|
| **ZO VM** | `ts8.zocomputer.io` (`150.136.143.138`) | `root` | 10661 | `~/.ssh/zeabur_key` | ✅ |

### SSH 快速指令
```bash
# Oracle
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ~/.ssh/zeabur_key opc@161.118.247.199

# ZO
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p 10661 -i ~/.ssh/zeabur_key root@ts8.zocomputer.io
```

### 已知問題
- Oracle 舊 IP `129.80.234.56` 已廢棄，現時用 `161.118.247.199`

## Hermes Backup（Oracle VM）設定

### 位置
- **Oracle VM:** `opc@161.118.247.199`
- **Backup 目錄:** `/home/opc/hermes-backup/`
- **News Summary:** `/home/opc/hermes-backup/news-summary/`
  - `news_summary.py` + `news_summary.sh`

### 結構
```
hermes-backup/
├── archive/
├── config/
├── inventory.yml
├── news-summary/      ← News Summary 脚本 ✅
├── README.md
├── scripts/           ← 各類工具脚本
├── setup-guide/
└── skills/
```

### 做法
- News summary 脚本喺 Oracle VM 呢度
- 同步去 Zeabur 用 `sync-all-vms.sh`

## Toolbox（2026-07-09）

- **Repo:** https://github.com/arslansky/toolbox
- **結構:** hermes/ (29 scripts) + openclaw/ (11 scripts) + shared/ + sync.sh
- **同步方式:** 直接 clone，唔用 symlink
- **每日 cron:** 04:00 Asia/Shanghai 自動 sync
- **Backup:** scripts.bak.20260709/ 保留舊版

