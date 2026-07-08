# TOOLS.md - Local Cheat Sheet

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

---

## 🌐 Network / Proxy

### 預設 Proxy（公開，用完即 unset）
- **Host**: `s4.hk38.ltip.xyz`
- **Port**: `20105`
- **User**: `utl`
- **Pass**: `mhd`
- **Protocol**: HTTP + SOCKS5 都 work
- **Hosting**: 華為雲（Hong Kong 命名但其實中國）
- **Ping**: 2.6ms（極快）
- **⚠️ 唔好用嚟過真密碼 / 真 API key**（public proxy 唔知 operator）
- **✅ OK 嚟 download public content**（YouTube audio、wiki、github release）

### Set / Unset
```bash
# Set
export http_proxy="http://utl:***@s4.hk38.ltip.xyz:20105"
export https_proxy="http://utl:***@s4.hk38.ltip.xyz:20105"
export all_proxy="socks5://utl:***@s4.hk38.ltip.xyz:20105"

# Unset
unset http_proxy https_proxy all_proxy
```

### yt-dlp 用 proxy

⚠️ **HTTPS over HTTP proxy 會撞 407**：public proxy 唔 support HTTPS CONNECT method

```bash
# HTTP proxy 過一般 webpage OK，但 yt-dlp 過 YouTube 會 407
yt-dlp --proxy "http://utl:***@s4.hk38.ltip.xyz:20105" -f "bestaudio[ext=m4a]" "URL"
# ❌ Tunnel connection failed: 407 Proxy Authentication Required

# ✅ Workaround：改用 SOCKS5（HTTPS over SOCKS 唔需要 CONNECT）
yt-dlp --proxy "socks5://utl:mhd@s4.hk38.ltip.xyz:20105" -f "bestaudio[ext=m4a]" "URL"
```

**Default 順序**：HTTP 試一次 → fail 即 fallback SOCKS5

### curl 用 proxy
```bash
curl -x "http://utl:***@s4.hk38.ltip.xyz:20105" https://api.ipify.org
```

---

## 🎙️ YouTube Transcript Pipeline（已驗證 work）

### 一行 command
```bash
PROXY="http://utl:***@s4.hk38.ltip.xyz:20105" && \
yt-dlp --proxy "$PROXY" -f "bestaudio[ext=m4a]" -o "/tmp/audio.%(ext)s" "URL" && \
ffmpeg -i /tmp/audio.m4a -ar 16000 -ac 1 -c:a pcm_s16le /tmp/audio.wav -y && \
whisper /tmp/audio.wav --model base --language Chinese --output_format srt --output_dir /tmp/subs
```

### 性能（部機 2 cores + 7.4GB RAM）
- 8 min video download: ~10s
- ffmpeg convert: ~5s
- whisper base STT: ~123s
- whisper small STT: ~7+ min（**唔好用**呢部機行 small）
- whisper medium STT: 估 15+ min（**唔好用**）

### 模型 cache
- `~/.cache/whisper/base.pt` 139MB
- `~/.cache/whisper/small.pt` 462MB
- base 已下載，立即可用

---

## 🔑 Google API Status

### 已 paste 過 chat log（要 revoke）
- `AIzaSy[REDACTED]`
- YouTube Data API: ✓ work
- Gemini API: ✗ `API_KEY_SERVICE_BLOCKED`

### GCP Project
- ID: `906487414422`
- Enable Gemini API: `https://console.developers.google.com/apis/api/generativelanguage.googleapis.com/overview?project=906487414422`

### YouTube Data API 範本
```bash
API_KEY="<新 key>"
# Video metadata
curl "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=VIDEO_ID&key=***}"
# Captions list
curl "https://www.googleapis.com/youtube/v3/captions?part=snippet&videoId=VIDEO_ID&key=***}"
```

---

## 💻 部機 Specs
- **Hostname**: `VM-17-222-ubuntu`（**cloud VM = YouTube block**）
- **Public IP**: `183.60.82.98`（中國雲）
- **Private IP**: `10.3.17.222`
- **RAM**: 7.4GB
- **CPU**: 2 cores
- **Disk**: 21GB available
- **OS**: Ubuntu 22.04 (kernel 6.8.0-51-generic)
- **特殊**: k3s 已裝

---

## 🛠 Installed tools
- `yt-dlp 2026.06.09` ✓
- `youtube-transcript-api` ✓（但 block 用）
- `whisper` (openai-whisper) ✓
- `ffmpeg 6.1.1` ✓
- `firecrawl` ✓
- `web_search` / `web_fetch` / `firecrawl_*` tools ✓

---

## 📂 重要文件
- `~/repos/openhuman/` — OpenHuman clone（125MB）
- `~/MEMORY.md` — long-term memory（永久）
- `~/memory/YYYY-MM-DD.md` — 今日 raw log
- `~/TOOLS.md` — 呢個 file

---

## 🦞 重要教訓（唔好再犯）

1. **先 recall tool / proxy / API key** — 唔好由零開始
2. **唔好「冇就 over」** — 試 4-5 個 method
3. **唔好交波畀用戶** — recall + prompt
4. **每次 session 開頭 read MEMORY.md** — 唔好由零開始
5. **API key 一 paste 就當 exposed** — 提示 user revoke
6. **🔴 嚴禁 truncated fake key**（用戶 2026-07-09 #7176 明令）：
   - 凡係 `xxx…yyy` 形式、`…` 係 unicode 字符（U+2026）或 heredoc 被 truncate、shell filter 補字符號嘅 key，都屬 truncated
   - 遇上 truncated key → **重搵完整 key**，**唔好將就**
   - **冇完整 key → 直接報錯、唔好誤判 backend 壞 / endpoint 死**
   - 浪費 call 浪費 token 之餘，仲會出錯結論（例如誤判 API key revoked）
