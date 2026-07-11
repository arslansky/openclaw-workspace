# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## GitHub

- arslansky (GitHub account)
- PAT: `ghp_[REDACTED]`

---

## VM SSH Config（2026-07-04 更新）

| VM | Host | User | Port | Auth | 用途 |
|---|---|---|---|---|---|
| **Oracle** | `161.118.247.199` | `opc` | 22 | SSH key (`zeabur_key`) | OpenClaw gateway ("Hermes"), backup target |
| **Zeabur** | `43.156.247.30` | `ubuntu` | 22 | Password | 主 OpenClaw ("openclaw-main"), primary |
| **ZO** | `ts8.zocomputer.io`（→ `150.136.143.138`） | `root` | 10661 | SSH key (`zeabur_key`) | Zo Computer VM |

### SSH Keys
- `~/.ssh/zeabur_key` — **已安裝**（2026-07-05），用於 ZO / Oracle 連接
  - 指紋：`zeabur-backup`（ssh-ed25519）
  - ⚠️ `129.80.234.56` 已廢棄（見 TOOLS.md SSH section），現時 Oracle IP 係 `161.118.247.199`
- ZO VM 已授權 `openclaw-zo` public key（可能與 `zeabur_key` 不同）

### SSH 快速指令
```bash
# Oracle → ZO
ssh -p 10661 -i ~/.ssh/zeabur_key root@ts8.zocomputer.io

# Oracle → Zeabur
ssh -i ~/.ssh/zeabur_key ubuntu@43.156.247.30

# ZO → Oracle（用 zeabur_key）
ssh -i ~/.ssh/zeabur_key opc@161.118.247.199
# 或用 config alias：ssh oracle-new
```

### Hostname 對照
| Hostname | IP |
|---|---|
| `oracle` / `oracle-01` | `161.118.247.199` |
| `zeabur` / `zeabur-01` | `43.156.247.30` |
| `ts8.zocomputer.io` | `150.136.143.138` |

---

## Vision / 睇圖 Model（2026-07-11 更新）
- **Default:** `kimi-code/k2p6`（已取代已死嘅 kimi-k2.6）
- **原因:** Kimi K2.6 中文 encoding 診斷最強，2026-07-11 確認有效
- **Fallback:** claude-opus-4-7（zhi-api），更適合需要深度推理嘅圖像分析
- **不可用:** deepseek-v4-pro（reject image_url）、gpt-5（503 no channel）
- **生效範圍:** 所有 TG bot，`image` tool 自動使用，唔需要手動指定 model

## Model 查詢規則（重要）

當用戶問「你係咩model」或類似問題：
- ✅ 只准用 `session_status` 工具查看 runtime 狀態
- ✅ 報告 `session_status` 顯示的 `🧠 Model:` 值
- ❌ 不准睇 config file
- ❌ 不准睇 backup file
- ❌ 不准憑記憶或假設
- ❌ 不准話「config 話...」

每次必須即時用 `session_status` 確認。

---

Add whatever helps you do your job. This is your cheat sheet.

---

## Telegram Bot Token 驗證（重要教訓）

**千祈唔好用省略格式嘅 token 測試 API！**

省略 token（如 `820547…xmgE`）係俾人睇嘅，唔係俾 API 用嘅。

**正確做法：**
```bash
# 永遠從 openclaw.json 拎完整 token
TOKEN=$(cat ~/.openclaw/openclaw.json | jq -r '.channels.telegram.accounts.zo.botToken')
curl -s "https://api.telegram.org/bot${TOKEN}/getMe"
```

詳見：`memory/SYSTEM-LESSONS.md`

---

## Telegram / OpenClaw 疑難排解

### arslanskybot 無反應 - Debug Checklist

**症狀：** groups 收唔到 messages，但 DM 正常

**Quick Fix #1（最常見）：accounts 撞 token**
```bash
# 1. 睇 health 有冇 error
openclaw gateway call health | jq '.channels.telegram'

# 2. 對比所有 accounts 嘅 token
cat ~/.openclaw/openclaw.json | jq '.channels.telegram.accounts | to_entries[] | {name: .key, token: .value.botToken}'

# 3. 如果有 duplicate → 刪多餘嘅 account，restart gateway
openclaw gateway restart
```

**Quick Fix #2：privacy mode**
```bash
curl -s "https://api.telegram.org/bot<TOKEN>/getMe" | jq '.result.can_read_all_group_messages'
# false → @BotFather → /setprivacy → Disable
```

**直接打 Telegram API 確認**
```bash
curl -s "https://api.telegram.org/bot<TOKEN>/getUpdates?timeout=5"
```

**Key Lessons:**
- `connected: true` 唔代表 channel work → 要睇 `configured` 同 `lastError`
- 兩個 OpenClaw instances 同一 token → 爭 updates
- Config 改完要 restart gateway（auto-reload 有時唔夠快）

---

## YouTube 字幕提取

### Proxy
- **Address:** `s4.hk38.ltip.xyz`
- **Port:** `20105`
- **User:** `utl`
- **Password:** `mhd`
- **Type:** SOCKS5

### YouTube API
- **Key:** `AIzaSy[REDACTED]`
- 字幕 download 要 OAuth，API key 只適合 metadata/search

### 提取方法
```shell
# Method 1: youtube_transcript_api via SOCKS5 proxy
python3 << 'PYEOF'
import socks, socket
socks.set_default_proxy(socks.SOCKS5, "s4.hk38.ltip.xyz", 20105, username="utl", password="mhd")
socket.socket = socks.socksocket
from youtube_transcript_api import YouTubeTranscriptApi
api = YouTubeTranscriptApi()
tr = api.fetch("VIDEO_ID", languages=("zh-TW", "en", "zh"))
for entry in tr:
    print(f"{entry.start:.1f}s: {entry.text}")
PYEOF
```

Supported languages: zh-TW（手動製作）, 可 translate 做 en

## Related

- [Agent workspace](/concepts/agent-workspace)
