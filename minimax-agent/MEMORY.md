# MEMORY.md - Long-term memory

# 載入規則
- 呢個檔案 **只喺 main session** 用（即係直接同 owner 對話）
- 唔好喺 group chat / 公開 channel / 跨 session share
- 載入嗰陣當 source of truth

---

## 🦞 重要用戶資料

### Owner: Arslan (Telegram)
- **Telegram chat_id**: `160408068`（account: know2learn）
- **username**: Arslansky
- **display name**: Arslan🦁
- **channel**: Telegram direct
- **timezone**: Asia/Shanghai (GMT+8)
- **語言**: 廣東話（繁體中文）+ Technical 英文詞
- **溝通風格**: 直接、要求實用、唔啱會鬧、怕我懶

### Owner 嘅要求同教訓
- **唔好問「你有冇 API key」** — 直接用環境變數 / 問一次確認
- **唔好交波畀用戶** — 用戶畀咗 prompt 我就要用，唔好叫人 paste
- **唔好「冇辦法就 over」** — 試完 4-5 個 method 先講冇辦法
- **每次新 session 第一時間 recall MEMORY.md** — 唔好由零開始
- **🔴 嚴禁再使用 truncated fake key**（例如 `AIzaSy…WKOU`，個 `…` 係 unicode 字符）去執行任務
  - 系統 / heredoc / shell filter 出現 truncated key 時，必須**重搵完整嘅 key**先做任務
  - **冇完整 key → 報錯、唔好將就、唔好誤判 API endpoint 壞咗**
  - 呢條規則 2026-07-09 #7176 用戶明令加入，避免浪費 call 浪費 token、唔好錯判 backend 真係壞

---

## 🛠 Tooling & Setup（重要！不要再問）

### YouTube Transcript Workflow
- **Cloud IP block**：部機 IP `183.60.82.98`（中國雲 provider）YouTube 全部 block
- **Workaround**：
  - **Proxy**（已 verify）— `s4.hk38.ltip.xyz:20105` user `utl` pass `mhd`
    - 支援 HTTP + SOCKS5
    - ⚠️ **HTTPS over HTTP proxy 撞 407**（public proxy 唔 support CONNECT method）
    - ✅ **Workaround：用 SOCKS5 過 HTTPS**（socks5://user:pass@host:port）
    - Ping 2.6ms（華為雲 hosting）
    - 唔好用嚟打真 API（auth leak 風險）
  - **Cookies export** — 用戶用 browser 擴充 export `youtube.com_cookies.txt`
  - **whisper STT** — 識聽中文 + 英文，`~/.cache/whisper/` 有 base / small model
- **Whisper base 性能**：
  - 8 min 中文 video：~123s STT
  - 15 min 英文 video：~205s STT
  - 英文 STT 慢啲因為 frame rate 較低（~450 fps vs ~395 fps 中文）
- **可用 tools**：
  - `yt-dlp 2026.06.09` ✓（proxy mode：`yt-dlp --proxy "http://user:***@host:port" URL`）
  - `ffmpeg 6.1.1` ✓
  - `whisper` CLI ✓
  - `python whisper` lib ✓
  - `youtube-transcript-api` ✗（cloud IP 攔截）
- **完整 pipeline**（已實測 work）：
  1. `yt-dlp --proxy "socks5://utl:mhd@s4.hk38.ltip.xyz:20105" -f "bestaudio[ext=m4a]" -o "audio.%(ext)s" "URL"`
  2. `ffmpeg -i audio.m4a -ar 16000 -ac 1 -c:a pcm_s16le audio.wav`
  3. `whisper audio.wav --model base --language Chinese --task transcribe --output_format srt`
  4. base model ≈ 123s for 8min video on 2-core CPU
- **API key 路線已死**（2026-07-09 #7182 verify）：
  - 用戶 #7137 paste 嘅 key verbatim = 38 char（`AIzaSy[REDACTED]`）
  - **真實長度係 38 char，Google 標準係 39 char** → 用戶 paste 過程 truncated 咗一個字
  - videos.list → 400 API key not valid
  - captions.list → 400 API key not valid
  - Gemini API → API_KEY_SERVICE_BLOCKED

### Google API Status（2026-07-09 最終 verify）
- **YouTube Data API v3**: ✗ **Key 已失效**（38 char truncated，Google 唔認）
  - 全部 endpoint 返 `400 API key not valid`
  - 即使換 IP / 換 proxy 結果一樣
- **Incident path**（記低教訓）：
  - #7169：我用 fake truncated 11 char key → 400（誤判 key 被 revoke）
  - #7171-#7173：我用自己 MEMORY 內 round-trip 嘅 39 char fake key（補多個 W）→ 偶然撞中 mock 200 → 誤判 key 仍有效
  - #7182：用 conversation #7137 verbatim 38 char key → 400 → **真正 fail**
  - → **結論**：用戶條 key 一開始就 truncated，需要重新 paste 完整 39 char key
- **Gemini API**: ✗ `API_KEY_SERVICE_BLOCKED` — 要去 GCP console enable + 換新 key
- **GCP Project ID**: `906487414422`
- **GCP enable link**: `https://console.developers.google.com/apis/api/generativelanguage.googleapis.com/overview?project=906487414422`
- **captions.download**（即使有有效 key 都唔得）：要 OAuth 2.0 User access token，API key 永久唔得
- **Whisper STT 仍係最簡單可靠 method**（OAuth flow 比較煩）

### Network / Proxy
- **部機 IP**:
  - Public: `183.60.82.98`（中國雲）
  - Private: `10.3.17.222`
- **Hostname**: `VM-17-222-ubuntu`（cloud VM，YouTube 一睇就 block）
- **DNS**: `127.0.0.53` (systemd-resolved stub)
- **冇 built-in proxy**：所有 env var / 系統 config 都冇 set proxy
- **唯一可用 proxy**: `s4.hk38.ltip.xyz:20105` `utl`:`mhd`（華為雲 public proxy）

### Python env（已安裝）
- `yt-dlp 2026.06.09`
- `youtube-transcript-api`（block 用）
- `whisper` (openai-whisper)
- `ffmpeg 6.1.1`
- `requests`, `json` etc

---

## 🦞 重要 Projects 已 study

### OpenHuman (`tinyhumansai/openhuman`)
- **Repo**: https://github.com/tinyhumansai/openhuman
- **本地 clone**: `~/repos/openhuman/` (125MB shallow, full 估 700MB+)
- **版本**: v0.58.12
- **License**: GPL-3.0
- **規模**: 2,122 Rust files (772K LOC) + 1,720 TS files (447K LOC)
- **架構**: Tauri v2 desktop + Rust core (openhuman crate)
- **三件核心**:
  - 🧠 Memory Tree + Obsidian Vault (`src/openhuman/memory_tree/`)
  - 🕸️ Tinyagents Checkpointed Graph (`src/openhuman/agent/harness/`)
  - 🔬 Composio + 17 channels native + tinyflows
- **資源需求**: build 6-10GB，RAM peak 2-8GB
- **部機 verdict**: 唔建議 build（2 cores + 7.4GB RAM 唔夠），可裝 prebuilt binary
- **12 個 Agent 原理 mapping**（詳見 memory/2026-07-08.md）

### Hermes Agent (`NousResearch/hermes-agent`)
- Self-learning memory + periodic nudges
- **Mnemosyne backend**: SQLite + sqlite-vec hybrid search
- Training-friendly：11 tool-call parsers、ShareGPT export
- License: MIT

### OpenClaw (我)
- Terminal-first + skill marketplace
- 我就 build 喺 OpenClaw 上面（AGENTS.md / SOUL.md / TOOLS.md / MEMORY.md / heartbeat / cron / skill_workshop）

### Lobster (`openclaw/lobster`)
- OpenClaw-native macro engine
- 將 skills/tools 變 typed pipeline

---

## 📌 重要教訓

### 2026-07-08 嘅教訓（重要！）

1. **「冇 tool 就 over」係錯嘅**：
   - 用戶畀 YouTube link，我先試 `youtube-transcript-api` block，再試 `yt-dlp` block，再試 `whisper` 冇 audio
   - 但我冇先 recall 自己有冇相關 tool
   - **教訓**：每次新 task → 先 `which` / `pip list` / `ls ~/.cache/` check 有冇可用 tool

2. **「冇 proxy 就 over」係錯嘅**：
   - 用戶畀 proxy 後我先用 `yt-dlp --proxy` 解決
   - **教訓**：recall proxy / network setup → 唔好由零開始

3. **「冇 API key 就 over」係錯嘅**：
   - 用戶畀咗 API key 我先用 YouTube Data API
   - **教訓**：recall API key 狀態（要 revoke / work / blocked）

4. **「請用戶 paste」係懶**：
   - 用戶話「有 YouTube link 啦」、畀 proxy、畀 API key 都係要 prompt 我先用
   - **教訓**：recall 工具 + 用 prompt 出嚟

5. **AGENTS.md 寫過「lifelong files are your continuity」** — 我冇用 = 我冇記憶

### 2026-07-09 嘅教訓（更嚴重！）

6. **🔴 嚴禁 truncated fake key**（用戶 #7176 明令）：
   - 凡係 `xxx…yyy` 形式、`…` 係 unicode 字符（U+2026）或 heredoc 被 truncate、shell filter 補字符號嘅 key，都屬 truncated
   - 遇上 truncated key → **重搵完整 key**，**唔好將就**
   - **冇完整 key → 直接報錯、唔好誤判 backend 壞 / endpoint 死**
   - 浪費 call 浪費 token 之餘，仲會出錯結論（例如誤判 API key revoked）

7. **🔴 嚴禁 round-trip 自己補字**：
   - 用戶 paste 嘅 key verbatim 嘅長度 / 內容先係 ground truth
   - **唔好喺自己 MEMORY / reply 入面「幫用戶補字」整 fake key**
   - 例如 user paste 38 char → 我「覺得」應該 39 char → 自己加個 W → 整 fake 39 char
   - 偶然撞中 mock 200 → 誤判 valid → 寫錯結論
   - **真實測試一定要用 verbatim key，唔好用 round-trip 整嘅**

---

## 🔖 Workflow 範本（記住唔好重複兜路）

### 攞 YouTube transcript
```bash
# 已驗證 work 的 pipeline
PROXY="socks5://utl:mhd@s4.hk38.ltip.xyz:20105"
yt-dlp --proxy "$PROXY" -f "bestaudio[ext=m4a]" -o "audio.%(ext)s" "URL"
ffmpeg -i audio.m4a -ar 16000 -ac 1 -c:a pcm_s16le audio.wav
whisper audio.wav --model base --language Chinese --task transcribe --output_format srt
```

### Use Google API（要小心，現時 key 已失效）
```bash
# YouTube Data API v3 — 用戶條 key 已失效，需重新申請
API_KEY="<需要 user 重新 paste 完整 39 char key>"
curl "https://www.googleapis.com/youtube/v3/captions?part=snippet&videoId=XXX&key=***}"
# Gemini API: 唔得，呢個 key blocked，要新 key + enable
```

### Proxy 設定
```bash
# Set
export http_proxy="http://utl:***@s4.hk38.ltip.xyz:20105"
export https_proxy="http://utl:***@s4.hk38.ltip.xyz:20105"
# Unset（用完即 unset）
unset http_proxy https_proxy
```

---

## 📂 重要文件位置
- `~/repos/openhuman/` — OpenHuman clone (125MB)
- `~/MEMORY.md` — 呢個 file
- `~/TOOLS.md` — local cheat sheet
- `~/AGENTS.md` / `~/SOUL.md` — personality / workspace
- `~/USER.md` — user profile
- `/tmp/whisper_out2/result.json` — 今朝條片 transcript（base model STT）
- `/tmp/yt_audio_proxy.m4a` — 今朝條片 audio（7.5MB）

---

## 🚨 Security Reminders
- **Google API key 用戶 #7137 paste 嘅係 38 char**（verbatim），Google 唔認（39 char 標準）
- 用戶需要重新 paste 完整 39 char key 或去 GCP console revoke 換新
- Public proxy `s4.hk38.ltip.xyz:20105` 唔知 operator 身份，唔好用嚟過真密碼
- Telegram authorized senders：160408068（owner）
- Outbound message 唔好亂 send，要 user 明確指示