# System Architecture（持續更新）

> 📌 每次架構變動後更新此文件。
> ⚠️ 此文件在 toolbox repo 管理，但 OpenClaw workspace 內有本地副本。

---

## VM 清單

| VM | Hostname | IP | User | SSH Port | SSH Key | 主要角色 |
|----|----------|-----|------|---------|---------|---------|
| **Hermes** | oracle | `161.118.247.199` | `opc` | 22 | `~/.ssh/zeabur_key` | OpenClaw gateway（備份），hermes-backup scripts |
| **OpenClaw** | zeabur | `43.156.247.30` | `ubuntu` | 22 | Password/SSH key | **主 OpenClaw gateway**，日常所有 bots |
| **ZO** | ts8.zocomputer.io | `150.136.143.138` | `root` | 10661 | `~/.ssh/zeabur_key` | ZO Computer VM，**未完成 bootstrap** |

### SSH 快速指令
```bash
# Hermes
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ~/.ssh/zeabur_key opc@161.118.247.199

# ZO
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p 10661 -i ~/.ssh/zeabur_key root@ts8.zocomputer.io
```

---

## Telegram Bots 註冊表

| Bot | Bot Token | Username | Display | 主要用途 | 狀態 |
|-----|-----------|---------|---------|---------|------|
| `arslansky` | `8688406477:AAF…` | @arslanskybot | Kimi Boy | 主要私人對話、group ingress | ✅ |
| `janzaibot` | `8302835438:AAH…` | @Janzaibot | Big VM | 用途待確認 | ⚠️ |
| `know2learn` | `8401590390:AAE…` | @Know2learn_bot | 知識庫熔爐 | 知識庫 inbox capture | ⚠️（forum group ingress 壞）|
| `zo` | **待加入** | **待加入** | ZO Computer Bot | ZO VM bot | ❌ 未配置 |
| `hermes` | `8755148273:AAEM…` | **未知** | **未知** | Hermes VM 專用？ | ⚠️ 發現但未確認 |

> 💡 know2learn group ingress 修復需 `/deletebot` + `/newbot`（Telegram 不支援 forum + non-forum bot 切換）

---

## Script 管理：Toolbox

**Canonical Repo：** `https://github.com/arslansky/toolbox`

```
toolbox/
├── hermes/          29 scripts（Oracle VM 專用）
├── openclaw/         11 scripts（Zeabur VM 專用）
├── shared/          1 script（雙方共用）
├── sync.sh          Bootstrap + rsync 橋接 script
└── README.json       Metadata
```

### Sync 機制（兩邊 VM 一致）
- **觸發：** 每日 04:00 Asia/Shanghai cron
- **流程：** `git pull` → `rsync owned scripts` → `cp shared/*` → `chmod +x`
- **Log：** `toolbox-sync.log`
- **版本標記：** `.toolbox-version`

### 廢除 Symlink（2026-07-09 決定）
- ❌ 舊方案 symlink → `$0` relative path 全部爆（80% scripts 受影響）
- ✅ Plan B 直接 clone → real files，無單點故障

### Backup
| VM | Backup 位置 | 備份時間 |
|----|------------|---------|
| OpenClaw | `scripts.bak.20260709/` | 2026-07-09 |
| Hermes | `hermes-backup.bak.20260709/` | 2026-07-09 |

---

## GitHub Repos

| Repo | URL | 用途 | 狀態 |
|------|-----|------|------|
| `arslansky/hermes-backup` | github.com/arslansky/hermes-backup | Hermes VM 備份（舊） | ✅ 正常 |
| `arslansky/toolbox` | github.com/arslansky/toolbox | **統一 script registry** | ✅ 正常 |
| `arslansky/openclaw-workspace` | github.com/arslansky/openclaw-workspace | OpenClaw workspace 備份 | ❌ **404 — 已斷** |

> ⚠️ `openclaw-workspace` 404，需要盡快修復（ recreate 或從頭 push）

---

## OpenClaw Agents

| Agent | Session Key Fragment | Model | 主要用途 |
|-------|---------------------|-------|---------|
| `arslansky-agent` | `telegram:direct:160408068` | MiniMax-M2.7 | 主私人助理 |
| `ds-agent` | 獨立 session | DeepSeek v3 | 深度分析任務 |
| `minimax-agent` | 獨立 session | MiniMax-M3 | 高階推理任務 |

---

## Cron Jobs

| Job | Schedule | Target | 用途 |
|-----|---------|--------|------|
| `toolbox-daily-sync` | 04:00 daily | isolated | Toolbox git pull + sync |
| `Weekly Inbox Review` | Sat 10:00 | know2learn session | 每週六回顧知識庫 inbox |

---

## 待完成工作（TODO）

- [ ] ZO VM 尚未 bootstrap toolbox
- [ ] `openclaw-workspace` GitHub repo 需要 recreate 或修復
- [ ] Hermes bot token `[BOT_TOKEN_REDACTED]` 需要確認用途
- [ ] `janzaibot` 用途待確認

---

## Changelog

| 日期 | 變動 |
|------|------|
| 2026-07-09 | 廢除 symlink，採用 Plan B 直接 clone toolbox；建立 `arslansky/toolbox` 統一 script registry；兩邊 VM 完成 bootstrap |
| 2026-07-09 | 建立 `toolbox-daily-sync` cron（04:00 daily，Asia/Shanghai）|
| 2026-07-09 | 發現 `openclaw-workspace` GitHub repo 404（backup 已斷）|
| 2026-07-05 | `zhi-api/kimi-k2.6` 死亡，image model 需更換 |
