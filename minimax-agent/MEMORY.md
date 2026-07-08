# MEMORY.md — Long-term memory

**只喺 main session** 用（即係直接同 owner 對話）。唔好喺 group chat / 公開 channel / 跨 session share。

---

## 🦞 重要用戶資料

### Owner: Arslan (Telegram)
- **Telegram chat_id**: `160408068`（account: know2learn）
- **username**: Arslansky  ·  **display**: Arslan🦁
- **channel**: Telegram direct
- **timezone**: Asia/Shanghai (GMT+8)
- **語言**: 廣東話（繁體中文）+ Technical 英文詞
- **風格**: 直接、要求實用、唔啱會鬧、怕我懶

### Owner 嘅要求同教訓
- **唔好問「你有冇 API key」** — 直接用環境變數 / 問一次確認
- **唔好交波畀用戶** — 用戶畀咗 prompt 我就要用，唔好叫人 paste
- **唔好「冇辦法就 over」** — 試 4-5 個 method 先講冇辦法
- **每次新 session 第一時間 recall MEMORY.md** — 唔好由零開始

---

## 🛠 Tooling & Setup

### Cloud VM
- **Hostname**: `VM-17-222-ubuntu`（中國雲, YouTube 一睇就 block）
- **Public IP**: `183.60.82.98`  ·  **Private**: `10.3.17.222`
- **Spec**: 2 cores, 7.4 GB RAM, 21 GB disk
- **冇 built-in proxy** — 唯一 proxy: `s4.hk38.ltip.xyz:20105` user `utl` pass `mhd` (華為雲, public)

### Proxy 設定（已 verify）
```bash
# set
export http_proxy="http://utl:mhd@s4.hk38.ltip.xyz:20105"
export https_proxy="http://utl:mhd@s4.hk38.ltip.xyz:20105"
export all_proxy="socks5://utl:mhd@s4.hk38.ltip.xyz:20105"

# unset（用完即 unset）
unset http_proxy https_proxy all_proxy
```
⚠️ HTTPS over HTTP proxy 撞 407（public proxy 唔 support CONNECT）→ 改 SOCKS5。
⚠️ Public proxy 唔知 operator 身份，唔好用嚟過真密碼。

### Python env（已安裝）
- `yt-dlp 2026.06.09` ✓
- `ffmpeg 6.1.1` ✓
- `whisper` (openai-whisper) ✓
- `youtube-transcript-api` ✗（cloud IP 攔截）
- `requests`, `json`, `sys`, `time`

### Whisper STT 性能（VM 2-core）
| Audio duration | Model | STT time |
|---|---|---|
| 8 min 中文 | base | ~123s |
| 15 min 英文 | base | ~213s |
| 15 min 英文 | small | 7+ min（唔建議） |

### Google API Status (2026-07-09 最終 verify)
- **YouTube Data API v3**: ✗ key 已失效（用戶 #7137 paste 嘅係 38 char，Google 標準 39 char → truncated）
- **Gemini API**: ✗ `API_KEY_SERVICE_BLOCKED`
- **captions.download**: 即使有有效 key 都唔得 — 要 OAuth 2.0 User access token
- 用戶需要重新 paste 完整 39 char key 或去 GCP console 換新

---

## 📦 yt-subs Pipeline（v2.0 strict-mode, 2026-07-09）

### 路徑
`memory/2026-07-09/yt-subs/`
- `yt-subs.sh` 8.7 KB — dispatcher
- `lib-config.sh` 3.6 KB — proxy / paths / helpers / exit-semantics
- `step1-ytdlp-subs.sh` — yt-dlp auto-subs
- `step2a-download-audio.sh` — yt-dlp audio
- `step2b-ffmpeg-wav.sh` — 16k mono wav
- `step2c-whisper-stt.py` — whisper (argparse, exit codes)
- `yt-subs-poll.sh` — PID-watch + log inspect
- `README.md` + `CHANGELOG.md` + `test-stt-output.json` (160 KB)

### Pipeline order
1. 🥇 yt-dlp --write-auto-subs via SOCKS5 (5-10s)
2. 🥈 Whisper base STT (3-4 min for 15 min audio, fallback only)
3. ⚠️ YouTube Data API — permanent skip (OAuth required)

### Anti-bot
- 2026-07-09 起 YouTube innerTube API 對 datacenter IP + 冇 cookies 嘅 yt-dlp 直 access 攔截
- 解決：export cookies 落 `~/.yt-cookies.txt` (Netscape format)
- dispatcher 已支援 `COOKIES_FILE=~/.yt-cookies.txt ./yt-subs.sh URL`

### Exit codes (consistent across all scripts)
| Code | Meaning |
|------|---------|
| 0 | success |
| 2 | user input / usage error |
| 3 | YouTube auth block |
| 4 | missing tool / file |
| 5 | runtime error |

### Reference test pair (驗證用)
| URL | Expected | Re-test condition |
|-----|----------|-------------------|
| `https://youtu.be/cBgT0PG4JkM` | has subs → step1 fast path | with cookies |
| `https://youtu.be/5XI5bn_7tJw` | no subs → STT fallback path | with cookies |

### Known issues
- **Dispatcher fires step1 twice** if `set -e` is in outer scope (covered by v2.0 strict mode)
- **bash comment with backticks**: `\`...\`` inside a comment still tries command substitution. Always avoid backticks in bash comments.
- **`case` pattern with embedded `"`**: opening `*",` without matching `",*)` can cause bash parse fail
- **Public SOCKS5 exit IP can be burnt** by other users' abuse

---

## 🦞 重要 Projects 已 study

### OpenHuman (`tinyhumansai/openhuman`)
- **Repo**: https://github.com/tinyhumansai/openhuman
- **本地 clone**: `~/repos/openhuman/` (125MB shallow, full 估 700MB+)
- **版本**: v0.58.12  ·  **License**: GPL-3.0
- **規模**: 2,122 Rust files (772K LOC) + 1,720 TS files (447K LOC)
- **三件核心**: 🧠 Memory Tree + Obsidian Vault  ·  🕸️ Tinyagents Checkpointed Graph  ·  🔬 Composio + 17 channels native + tinyflows
- **部機 verdict**: 唔建議 build（2 cores + 7.4GB RAM 唔夠），可裝 prebuilt binary

### Hermes Agent (`NousResearch/hermes-agent`)
- Self-learning memory + periodic nudges
- **Mnemosyne backend**: SQLite + sqlite-vec hybrid search
- License: MIT

### OpenClaw + Lobster
- 我 build 喺 OpenClaw 上面（AGENTS / SOUL / TOOLS / MEMORY / heartbeat / cron / skill_workshop）
- Lobster = OpenClaw-native macro engine, typed pipeline

---

## 📌 重要教訓

### 2026-07-08
1. **「冇 tool 就 over」係錯** — 每次新 task 先 `which` / `pip list` / `ls ~/.cache/` check 有冇可用 tool
2. **「冇 proxy 就 over」係錯** — recall proxy 設定先
3. **「冇 API key 就 over」係錯** — recall key status
4. **「請用戶 paste」係懶** — recall 工具 + 用 prompt 出嚟
5. AGENTS.md 寫過「lifelong files are your continuity」— 我冇用 = 我冇記憶

### 2026-07-09
6. **🔴 嚴禁 truncated fake key**（用戶 #7176 明令）
   - `xxx…yyy` 形式（`…` 係 unicode U+2026）/ heredoc truncated / shell-filter 補字 → 全部 suspect
   - 必須重搵完整 key，唔好將就 / 唔好誤判 endpoint 壞咗
7. **🔴 嚴禁 round-trip 自己補字**
   - 用戶 paste 嘅 verbatim 長度先係 ground truth
   - 唔好喺自己 MEMORY / reply 入面「幫用戶補字」
   - 偶然撞中 mock 200 → 寫錯結論

### 2026-07-09 (教訓 8-12, thread #7218 audit)
8. **🔴 Host workspace wipe 中途可以發生**
   - AGENTS / SOUL / TOOLS / MEMORY rebuild, 但 user-written file 可能不見
   - **baseline commit 要先做, 唔好假設 filesystem 永續**
9. **🔴 bash comment 唔可以含 backticks**
   - `\`cmd\`` 喺 # 開頭嘅 comment 都會被 bash parser 視為 command substitution
   - 永遠唔好喺 bash comment 用 backticks 或 `"` (尤其喺 case pattern 度)
10. **🔴 `set -e` + 開頭 dispatch exit dispatch 嘅 fragile pattern**
    - `set -e` 環境下, 開始 main 之前 `usage; exit 2` 嘅 pattern 容易踩到
    - sub-shell capture 要 `set +e` ... `set -e` 包住
11. **🔴 function def 必須喺 caller call 之前**
    - `if [[ BASH_SOURCE == ${0} ]]; then main "$@"; fi` 喺 `function def` 之前 = main: command not found
12. **🔴 `--help` 嘅 exit code 一致性**
    - `--help` / `-h` → exit 0
    - 未知 arg / 冇 args → exit 2 + usage
    - 好多人 default `usage; exit 0` 令 caller 難判斷

---

## 🔖 Workflow 範本

### 攞 YouTube transcript（use dispatcher 已內建）
```bash
# Normal
./yt-subs.sh "URL"

# Anti-bot bypass
COOKIES_FILE=~/.yt-cookies.txt ./yt-subs.sh "URL"

# 驗證 command construction
./yt-subs.sh "URL" --dry-run
```

### 直接用 subprocess（debug 用）
```bash
PROXY="socks5://utl:mhd@s4.hk38.ltip.xyz:20105"
yt-dlp --proxy "$PROXY" -f "bestaudio[ext=m4a]" -o "audio.%(ext)s" "URL"
ffmpeg -i audio.m4a -ar 16000 -ac 1 -c:a pcm_s16le audio.wav
whisper audio.wav --model base --language English --task transcribe
```

### Proxy 設定
```bash
export http_proxy="http://utl:mhd@s4.hk38.ltip.xyz:20105"
export https_proxy="http://utl:mhd@s4.hk38.ltip.xyz:20105"
unset http_proxy https_proxy
```

---

## 📂 重要文件位置
- `~/repos/openhuman/` — OpenHuman clone (125MB)
- `~/MEMORY.md` — 呢個 file
- `~/TOOLS.md` — local cheat sheet
- `~/AGENTS.md` / `~/SOUL.md` — personality / workspace
- `~/USER.md` — user profile
- `~/memory/<YYYY-MM-DD>/` — daily log
- `~/memory/2026-07-09/yt-subs/` — yt-subs v2.0 dispatcher

---

## 🚨 Security Reminders
- Google API key 用戶 #7137 paste 嘅係 38 char（truncated），Google 唔認
- Public proxy `s4.hk38.ltip.xyz:20105` 唔知 operator 身份，唔好用嚟過真密碼
- Telegram authorized senders: `160408068` (owner)
- Outbound message 唔好亂 send, 要 user 明確指示
