<!-- LAST_SNAPSHOT=1783619334 -->
# MEMORY.md — Long-term memory

**只喺 main session** 用（即係直接同 owner 對話）。唔好喺 group chat / 公開 channel / 跨 session share。

---

## 🐛 Debug Cases Index

> **Folder**: `memory/<YYYY-MM-DD>/debug-cases/`
> **Naming**: `case-NN-<slug>.{md,pdf}`
> **Policy**: 任何 debug case-worthy issue 都要提煉成獨立 case, 唔好散落 daily log

| # | Slug | Date | Title | Lesson |
|---|------|------|-------|--------|
| 01 | mojibake-round-trip | 2026-07-11 | Telegram iOS Markdown preview parser fail | text/markdown MIME 不可靠, default 用 PDF |
| 02 | hooks-build-bugs | 2026-07-10 | 3 bash bugs in pre_compact_snapshot.sh | awk pipe buffer / dirname 嵌套 / 設計缺陷 document |

**完整 list**: 見各 daily memory folder 嘅 `debug-cases/README.md`

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
- **🔴 嚴禁 Telegram outbound 用 box-drawing chars** (用戶 #7406)
  - 唔好用 ╔═╗║╠╣╦╩╬ / ┌┐└┘├┤┬┴┼ 等 U+2500-259F
  - iPhone Telegram client render 時 fallback 出 ? 或 ?
  - 視覺分隔改用 ASCII: `===` `---` `***` `+++`
  - 仍可用嘅安全 char: `→` `✓` `•` `●` `▶` `→` (U+2192 / U+2713 / U+2022 / U+25CF / U+25B6, 全部 Apple+Android 預設 font 認)
  - File content 唔受影響 (都係普通 CJK+ASCII), 純 outbound message 限制
- **🔴 Default outbound file MIME = `application/pdf` 或 `text/plain`, 唔好 `text/markdown`** (用戶 #7418 + #7420)
  - text/markdown MIME 喺 iPhone TG client QuickLook Markdown preview parser fail, 繁中 + markdown control chars trigger font substitution
  - PDF (Quartz native render) + TXT (raw display) 完全 bypass parser, 兩個都 100% reliable
  - **Apply 範圍: ALL Telegram outbound file delivery**, 唔只 transcript (用戶 #7420 明令「apply 呢個嘢係 openclaw 全部 TG」)
  - Workflow: long content → markdown source file 永久存底 + render PDF + send `application/pdf`
- **🔴 長字幕 / 長編內容一律 TXT file delivery**（用戶 #7384 明令）
  - 唔好 inline 4 段 dump
  - 流程：clean text → copy to `~/memory/<YYYY-MM-DD>/yt-transcripts/<videoID>.<lang>.txt` (workspace allowlist) → `message` tool `action=send` + `media=` + `caption=`

---

## 🛠 Tooling & Setup

### Cloud VM
- **Hostname**: `VM-17-222-ubuntu`（中國雲）
- **Public IP**: `183.60.82.98`  ·  **Private**: `10.3.17.222`
- **Spec**: 2 cores, 7.4 GB RAM, 21 GB disk
- **冇 built-in proxy** — 唯一 proxy: `s4.hk38.ltip.xyz:20105` user `utl` pass `mhd` (華為雲, public)
- **YouTube 可達**: 2026-07-09 verified — VM + SOCKS5 proxy 直接 hit innerTube API 拎 subs OK (5-7 秒出 .vtt)。 舊话「一睇就 block」係 stale / wrong, 參考 「🩺 Anti-bot evidence」section.

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
- `youtube-transcript-api` ✓（裝咗，但 status ไม่ calibrate； prefer yt-dlp 因為 verified work）
- `requests`, `json`, `sys`, `time`

### Whisper STT 性能（VM 2-core）
| Audio duration | Model | STT time |
|---|---|---|
| 8 min 中文 | base | ~123s |
| 15 min 英文 | base | ~213s |
| 15 min 英文 | small | 7+ min（唔建議） |

### Google API Status (2026-07-09 最終 verify)
- **YouTube Data API v3**: ✗ user の key suspect truncated (user #7137 pasted 38 chars, Google standard = 39)
- **Gemini API**: ✗ `API_KEY_SERVICE_BLOCKED`
- **captions.download**: 即使有效 key 都要 OAuth 2.0 User access token; API key 不足
- **結論**: transcript 提取 path 完全唔靠 Google API; 走 yt-dlp + proxy

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
1. 🥇 yt-dlp --write-auto-subs via SOCKS5 (5-10s) — verified work on 2026-07-09
2. 🥈 Whisper base STT (3-4 min for 15 min audio, fallback only)
3. ⚠️ YouTube Data API — permanent skip (OAuth required, key truncated)

### 🩺 Anti-bot evidence (single source of truth)

**Claim**: VM + SOCKS5 proxy + 冇 cookies 直接 hit YouTube subs extraction — **works** for `https://youtu.be/-fSjdYzrFvA` (5-7 秒出 141KB en.vtt + multilingual siblings).

**Retracted stale claims**:
- ❗ 「YouTube 完全 block datacenter IP + 冇 cookies」 — false. SOCKS5 routing 過 innerTube API 喺呢個 stack 走通。
- ❗ 「SOCKS5 over public proxy 過唔到 HTTPS」 — outdated. yt-dlp XML/RPC sub-fetch 唔需要 CONNECT tunnel。

**Rate-limit caveat** (2026-07-09 08:30 observable):
- 同一 IP 短時間多次 hit subs endpoint → YouTube 返 HTTP 429 → 只主語 .vtt 寫到, 翻譯(s) 寫唔到。
- Workaround: dispatcher 落 step 時 set `--sub-langs` only what you need; 或者 sleep 60 sec retry; 或者 cookies 同事。
- dispatcher 已支援 `COOKIES_FILE=~/.yt-cookies.txt ./yt-subs.sh URL` (能開則閉, 未需要)。

### Exit codes (consistent across all scripts)
| Code | Meaning |
|------|---------|
| 0 | success |
| 2 | user input / usage error |
| 3 | YouTube auth block |
| 4 | missing tool / file |
| 5 | runtime error |

### Reference test pair (validated 2026-07-09 08:25)
| URL | Result | Path | Evidence |
|-----|--------|------|----------|
| `https://youtu.be/-fSjdYzrFvA` | 1-3× .vtt (en 141KB, zh-Hant 137KB, zh-Hans 152KB; count 看 429 luck) | step1 fast (5 sec, exit 0) | `/tmp/yt-subs/<TS>-<PID>.*.vtt` |
| `https://youtu.be/cBgT0PG4JkM` | ⏳ unregressed | with cookies / proxy | re-run when needed |
| `https://youtu.be/5XI5bn_7tJw` | ⏳ unregressed | with cookies / proxy | re-run when needed |

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

### 2026-07-09 (教訓 13, post-E2E audit, thread #7241-#7250)
13. **🔴 Theory > Evidence rule** (Evidence-First Rule)

### 2026-07-11 (教訓 14, rendering artifact, thread #7321)
14. **🔴 `[e~[` 結尾符號係 OpenClaw / provider SSE stream corruption，唔係 reply content**
    - **Symptom**: long-form reply 收尾位置 (Telegram messageId 7317/7318/7320/7324/7326/7328 etc.) 多次 render `[e~[`
    - **Trace evidence** (`/tmp/openclaw/openclaw-2026-07-11.log`):
      - provider = `minimax` api=`anthropic-messages` model=`MiniMax-M3` contentType=`text/event-stream; charset=utf-8`
      - Telegram outbound `sendMessage` `chunkCount=1` status ok — 表示 runtime 已 send 字串嘅完整版本
      - grep source / heredoc / Python: 0 hit `[e~[`
      - SSE event-stream delimiter boundary 漏咗 4 chars 出嚟，pattern = `[`, `e`, `~`, `[` (ASCII)
    - **結論**：OpenClaw runtime 將 anthropic SSE stream 嘅 raw bytes 打包入 TG reply 嘅 last partial chunk 時，stream 收尾 partial frame 嘅 4 bytes 被視作 message content，附加到 reply
    - **解法**：
      - (a) **唔留 hanging 半句**, 避免 stream 被中途截斷
      - (b) reply 結尾 add explicit 「EOF」或 newline（減少 stream truncation boundary）
      - (c) short reply (≤2000 字, 唔過 4096 Telegram message limit) — limit stream chunks 數量
      - (d) open OpenClaw runtime ticket / issue 將 個 byte-trimming bug patch
    - **User 明確 feedback** (#7321 「**盡量唔好再出現 [e~[**」) — 我 decide優先用 (a)+(b)+(c)：每次 ending 都乾淨收，多 round message verify
    - MEMORY 每次新 session recall 即 fixed
    - 「technical claim 要以 真· command + 真· output 為證」。 MEMORY 寫過嘅 prediction 唔等於 fact。
    - Default action hierarchy: 真· endpoint (5-30 sec cheap) > --dry-run / syntax-only (limit debug use only)
    - User 拍 URL 嚟 = 「真· user-facing test request」, 必須實 retry 先 reply
    - 2026-07-09 thread 5 round 衝突 class: 我 dedupe 複数 round 嘅 stale verdict, 浪費 token + 全個 conversation 混亂了

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

## 🎨 Fable 5 Prompting Rules（insight-006）

**Source**: YouTube - How Anthropic Engineers Actually Prompt Fable 5 (Nate Herk), 2026-07-06
**Obsidian**: `~/obsidian/knowledge/01-Atomic/insight-006_fable-5-prompting-rules-2026-07-06.md`
**Prompt-Archive**: `~/obsidian/knowledge/Prompt-Archive/Fable-5-Prompting-Rules.md`

**⚠️ SCOPE GUARDRAIL (2026-07-11 #7356 user explicit)**：Fable 5 rules 設計對象係 Anthropic Fable 5 model 嘅 Anthropic team usage pattern。**唔好當 universal prompting rule 套落一般 LLM work**。

具體嚟講：
- ✅ 套用：當 user 用 Fable 5 / Claude Opus 寫 email、寫文、做 narrative work、creative task 時
- ❌ 唔套：coding、debugging、system design、technical explanation、research analysis、data work
- ⚠️ Rule 5 (唔好叫佢解釋思維) 嘅「悄悄 routing 去 Opus」效應，係 Fable 5 safety guardrail 行為 — 其他 model 唔適用

**6 rules cheatsheet**:
1. **Give it the WHY** — 唔淨只講要做咩，要解釋 intent
2. **Negative prompt** — 講明「唔好做乜」，AI 容易 over-extend
3. **唔好 over-plan** — 有足夠資訊就 act，"When you have enough information to act, then act"
4. **Make it prove it** — 「Before you tell me done, point to the result that proves it」
5. **唔好叫佢 explain reasoning** — Fable 5 會悄悄 routing 去 Opus (safety)
6. **話少啲，唔好話多** — Fable 夠聰明，短指示已經有效

**When in doubt**: 唔好自動 apply。等 user/task context 明顯係 Fable 5 / creative writing 先 trigger。

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

