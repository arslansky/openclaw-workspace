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
| 03 | text-markdown-mime-repeat | 2026-07-11 | 重複違反 rule 16 (outbound index.md text/markdown) | pre-send mime audit + safe_send_markdown.py wrapper |
| 04 | minimax-agent-silent-4hr | 2026-07-12 → 07-13 | minimax-agent Silent 4hr (user-perceived 10.5hr outage) | session bridge deadlock + 14× tool-result-truncation + NO_REPLY 唔 announce = user panic |

**完整 list**: 見各 daily memory folder 嘅 `debug-cases/README.md`

**Session reflections**:
- 2026-07-11: [learnable-insights-2026-07-11.pdf](./memory/2026-07-11/learnable-insights-2026-07-11.pdf) — 8 sections 包括 outbound MIME rule, YT transcript pipeline 5-step, debug case methodology, PDF pattern, MEMORY architecture, self-reflection, permanent assets, future improvements

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
- **🔴 Outbound delivery** (用戶 #7406, #7418, #7420, #7465) [modified 2026-07-11]
  - **3 sub-rules merge 落 single mega-rule:**
    1. **No box-drawing chars** (rule 14) — 唔好用 ╔═╗║╠╣╦╩╬ / ┌┐└┘├┤┬┴┼ 等 U+2500-259F, iPhone TG client render fallback 出 ?。 視覺分隔改 ASCII: `===` `---` `***` `+++`。 安全 char: `→` `✓` `•` `●` `▶` (U+2192/2713/2022/25CF/25B6)。
    2. **Default file MIME = pdf/txt only** (rule 16) — text/markdown MIME 喺 iPhone QuickLook preview parser fail, 繁中 + markdown control chars trigger font substitution。 PDF + TXT 100% reliable。
    3. **No inline 4-paragraph dumps** (rule 15) — 長編一律 file delivery, 唔好 4 段 inline message dump。
  - **Workflow**: markdown source file 永久存底 + render PDF + send `application/pdf`。
  - **Apply 範圍: ALL Telegram outbound** (唔只 transcript)。
  - **🔺 Repeat violation warning** (#7465「要鬧了」): outbound #7463 (send index.md text/markdown) 我自己違反 own rule。 I MUST 自帶 **pre-send mime audit**。
  - **✅ System-level fix (Option C applied)**: `safe_send_markdown.py` script @ `memory/2026-07-11/yt-transcripts/scripts/safe_send_markdown.py` provides automatic markdown → PDF (+ TXT fallback) conversion. Default: `python3 safe_send_markdown.py <file.md>` → send `media=<file>.pdf`. Audit log @ `debug-cases/_audit/safe_send_markdown.jsonl`.

- **🔴 YT 英文 auto-caption 必須 dedupe consecutive dup lines** (用戶 #7438) [modified 2026-07-11]
  - YouTube 英文 auto-caption VTT format 用 **rolling window pattern** — 每段台詞出 3 次 (句首 / 句中 / 句尾 boundary)
  - 之前我 strip `<c>` + `<HH:MM:SS.mmm>` tags 之後, 文字本身一樣, 結果 730 lines 入面 66.6% 重複
  - Fix: collapse consecutive identical lines → 1 (ka_WCmNdybE: 730→244 lines, 28KB→9.4KB)
  - 中文字幕 (YT zh-Hans/zh-Hant) 唔受影響, 單行 non-rolling
  - 之後英文 transcript 預設 dedupe; yt-subs dispatcher 加返呢個 step
  - **YouTube transcript delivery 規范** (用戶 #7441):
    1. **第一份 .txt**: 保留**開始時間** (only), deduped (`[HH:MM:SS.mmm] text`) — **不要同時顯示 end time** (用戶 #7446 嫌冗長)
    2. **第二份 .txt** (optional): 純文字, deduped, no timestamp (方便讀)
    3. **永遠保留 .vtt**: raw 原始檔, 永久 backup (end time 資訊存 VTT 入面)
    4. 順序 send 時 first = timed (用戶參考時間軸用), second = clean (閱讀用)
  - **🔴 YT transcript → 中文 PDF summary 為 default** (用戶 #7458 明令「之後唔駛我掂」)
    - 用戶 send YouTube URL → default pipeline: 攞 transcript (timed+clean) → **自動 distill + render 中文 PDF summary** → send file delivery
    - 唔再等用戶 explicitly confirm 「做 PDF」
    - 中文 PDF 沿用 `zh-pdf-template.py` style (繁體, cover / TOC / divider / 4 種 callout / 表格 / takeaway, 無 emoji logos)
    - 71+ 分鐘 long video 用 cover page + sections, distillation 注意 STT 錯字 caveats (whisper base 中文有限制)
  - **🔴 yt-transcripts folder 統一管理** (用戶 #7461 明令「归納 統一處理 存放 有記錄 可追溯」)
    - Folder structure: `memory/<YYYY-MM-DD>/yt-transcripts/<videoID>/` (每條影片一個 subfolder)
    - Files: `<videoID>.timed.<lang>.txt` + `<videoID>.<lang>.txt` + `<videoID>.summary.zh-Hans.pdf` + raw (`.vtt`/`.whisper.json`/`.wav`)
    - Scripts 統一放 `yt-transcripts/scripts/` subfolder
    - 每處理完一條新影片, **必須 append row 落 `yt-transcripts/index.md`** (index.md + README.md 永久)
    - 永久保留 transcript / summary files (永久 audit trail); `.wav` 預設 3 個月 cleanup (raw STT json 永久)
    - Naming convention 嚴格遵守: `<videoID>.<lang>.{txt,timed.txt,vtt,whisper.json,wav,pdf}`
- **🔴 Net-zero policy (system growth budget)** (用戶 #7486-#7489「會唔會越加越長」「諗吓點可以解決日加長既問題」)
  - **核心**: 每加一個新 artifact (rule / case / script / doc) → 必須 retire / consolidate 至少一個 existing 同impact artifact。
  - **Lighthouse check** (add new artifact 前必答): "What specific failure 呢個 prevents?" — 答唔出即 reject。
  - **Inventory audit (凍結合規)**: 每個 category 維持一個 entry per pattern，唔加 noise scripts / 唔加 dead rules。
  - **Examples**:
    - Add new PDF render script → 必須 retire 1 個舊 PDF render script。
    - Add case-04 → 必須先 merge case-01+03 (兩者都係同一 issue) 為 single case。
    - Add new rule 17 → 必須 retire 1 個舊 rule 或 merge 入 mega-rule。
  - **Audit 2026-07-11**: 已 archive 3 noise scripts (`gen_summary_pdf.py`, `gen_summary_pdf_v2.py`, `ka_summary_pdf.py`) → `scripts/_archive/`。 -62KB noise 移除。

- **🔴 Explain format: 背景 / 經過 / 影響 / 要做乜 / 選項** (用戶 #7505 明令「剛才啲問題背景、影響、要做乜、選項呢種表達幾好, 日後都可以咁用, 記住」)
 (用戶 #7505 明令「剛才啲問題背景、影響、要做乜、選項呢種表達幾好, 日後都可以咁用, 記住」) [modified 2026-07-11]
  - 每次 complex decision / 多 round 包会都依這個 5-section format:
    1. **背景** (1 句): 當時 evidence-context
    2. **經過** (3 句以內): chronological key events
    3. **影響** (具體 numeric/data): 量化 impact
    4. **要做乜** (1 keyword reply-friendly): user 議程表
    5. **選項** (A/B/C/D/all/none): simple decision matrix
  - 避免抽象 jargon + multi-paragraph lecture
  - 呢個 format user approve 後 — 永久 default 之後複雜 topic / debug discussion / multi-step decisions 都用同一個 template
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

## 🗺️ Finding Your Unknowns（insight-007, 2026-07-15）

**Source**: YouTube - Anthropic 大神的用 AI 心法（Paula 寶拉, 2026-07-12）
**Original**: Thariq Shihipar 《Finding Your Unknowns》(Anthropic)
**Full digest**: `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/_1IM9ZpmEWc.summary.zh-Hant.pdf`

**Core sentence**: 樽頸由「模型識唔識做」搬咗去「我講唔講得出我唔知嘅嘢」。

**4 種「不知道」** (旅行社例子):
- known-knowns → 入 prompt 就算
- known-unknowns → 你知未決定，但一直拖
- unconscious-knowns → 你視為理所當然，唔會講
- unknown-unknowns → 你連聽都未聽過

**4 個挖法**:
1. **Blind spot scan** — 直接叫 AI：「Run a blind spot scan for me. Tell me the things I don't know I don't know.」
2. **AI 反訪問** — 叫 AI 反過嚟訪問你，一次一條，由「會改變成個方向」嗰啲開始
3. **幾個差好遠版本** — 你講唔出但一睇就知，畀 4 個完全唔同方向嘅版本你揀
4. **直接畀範例** — 你手上有現成 example 就直接交，唔好靠自己形容

**互補 Fable 5 (insight-006)**:
- Fable 5 rule 1 (Give it the WHY) ↔ 旅行社例子（怕行路 = WHY）
- Fable 5 rule 2 (Negative prompt) ↔ 方法三「幾個差好遠版本」排除方向
- Fable 5 rule 3 (唔好 over-plan) ↔ 方法一 blind spot scan 用最 cheap step 偵察

**套用範圍**：
- ✅ User 撞 silent gap / multi-round conflict / 我哋自己答錯 — 應該用 blind spot scan prompt 自己問自己
- ✅ User 開新 task — pipeline 開頭做一次 blind spot scan 確認所有 known-unknown 都挖出嚟
- ✅ Debug complex case（case-04 等）— 用 4-type framework 拆解 root cause，避免 known-unknown 變地雷

**Net-zero**: 已經寫入 yt-transcripts/index.md row 8 + topic cross-ref「Prompting patterns (Fable 5 + Unknowns)」。 PDF 同 script (`render_summary_pdf.py`) 永久保留。

---

## 🎨 PDF Summary Font Default (2026-07-16)

**User decision** (#7668 reply): **Serif 為英文字體**

- **default latin**: `DejaVuSerif` (TTF, embed-able, 學術 serif 風格)
- **default cjk**: `STSong-Light` (CID, 全 CJK 覆蓋)
- **rationale**: Helvetica 細字 (9-10.5pt) 瘦仔 reading 不舒服；iPhone QuickLook preview 對 Helvetica fallback render 差
- **alternatives archive 咗**: DejaVuSans、Helvetica、MSung-Light（皆唪唥 render-script 可用）
- **script**: `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/scripts/render_summary_pdf.py`
  - `DEFAULT_LATIN = "DejaVuSerif"`, `DEFAULT_CJK = "STSong-Light"`
  - Usage: `python3 render_summary_pdf.py <out.pdf>` (one-arg use default)
  - Override: `python3 render_summary_pdf.py <out.pdf> DejaVuSans MSung-Light`
- **Apply scope**: 所有 future zh-Hant PDF summary（YT transcript 之外都適用）

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

### 2026-07-13
15. **🔴 Outbound media path 必須喺 OpenClaw workspace** (用戶 #7630, lesson from 5+ 小時 stuck recovery)
    - `/home/ubuntu/memory/...` **唔喺** OpenClaw outbound allowlist → `OutboundDeliveryError: Local media path is not under an allowed directory`
    - **Workaround**: copy 入 `/home/ubuntu/.openclaw/workspace/minimax-agent/memory/...` 先可以 send
    - 或者直接放 workspace `/home/ubuntu/.openclaw/workspace/minimax-agent/...`
    - MEMORY outbound rule 已經 require PDF/TXT, 但**路徑都必須係 workspace** — 否則 tool 拒絕送
16. **🔴 Workspace wipe 已 confirmed** (2026-07-12 → 2026-07-13 only)
    - 之前 reference 嘅 `~/memory/2026-07-11/yt-transcripts/scripts/*.py`, `safe_send_markdown.py` 全部唔見咗
    - 只能由 workspace wipe 之前 commit 過嘅 MEMORY.md 拎回 context (which is current)
    - **Lesson**: 自己寫嘅 script 必須 sync 入 workspace git, 或者 copy 落 `~/skills/` (用戶原位長期保留)
17. **🔴 Noto CJK font 唔可以用 reportlab 直接 load** (2026-07-13 #7630 PDF 階段)
    - `/usr/share/fonts/opentype/noto/NotoSansCJK-*.ttc` 係 CFF/PostScript
    - reportlab error: `TTFont: postscript outlines are not supported`
    - **Solution**: 用 built-in CID font `STSong-Light` (覆蓋全 CJK chars 包括繁中), or `/usr/share/fonts/truetype/wqy/wqy-microhei.ttc` (但 SKILL script 路徑寫錯)
    - 直接 inline Python script render PDF, 唔靠 SKILL script
18. **🔴 YT 短片 (< 5 min) zh-Hant/zh-Hans 容易撞 429** (2026-07-13 T3K9r3wDoO8)
    - 同 session 短時間攞 en + zh-Hant → 後者 429
    - 短片 en 完全足夠 — 中文 PDF summary 自己 distill 就 OK
    - Workaround: sleep 60s retry, 或只用主語


### 2026-07-16
19. **🔴 PDF 英文 default = Serif font** (用戶 #7668 明令)
    - `render_summary_pdf.py` DEFAULT_LATIN = DejaVuSerif, DEFAULT_CJK = STSong-Light
    - One-arg usage: `python3 render_summary_pdf.py <out.pdf>`
    - 4 個 variant 永久 archive: A=Helvetica/B=DejaVuSans/C=DejaVuSerif/D=DejaVuSans+MSung
    - Helvetica 細字 9-10.5pt reading 偏瘦 → 唔再 default
20. **🔴 PDF CJK render — NEVER wrap CJK text in Latin TTF inline** (用戶 #7672 即時 feedback)
    - DejaVuSerif / DejaVuSans / Helvetica 都係 Latin-only TTF
    - `<font face="DejaVuSerif">繁中字</font>` 無論 inline 定 Table cell → render 空白 box (■■■■)
    - **Solution**: ParagraphStyle.fontName 一律用 CID font (STSong-Light / MSung-Light)，CID 內部 fallback chain 自動處理 Latin chars
    - Pure-Latin paragraph (English quote / prompt) 至用 Latin TTF，但要 `_has_cjk()` detect
    - **Debug case**: `memory/2026-07-16/debug-cases/case-05-pdf-cjk-font-blank-boxes.md`
    - **Verify routine**: re-render 後必 extract text，count `■■` + `<font` literal，必須 = 0

### Skywork (Kunlun Wanwei 万仑万萬 / Kunlun Tech) — 2026-07-16 #6263

**Quick ref**:
- 內地 top LLM team (天工 / Skywork team)，2023-10 開源 Skywork-13B 起家
- ~400M MOU，78% revenue overseas；港股上市
- 多模路線: LLM + video gen + voice + reward model
- User 2026-07-16 揀 D = reference only, no deploy, no paid

**完整產品線**:

| 產品 | 類型 | Size | 用途 | License / 收費 |
|---|---|---|---|---|
| `Skywork-OR1` | Reasoning LLM | 7B / 32B | math / code | open source (Apache-2.0) |
| `Skywork-OR1-Math-7B` | Math reasoning | 7B | AIME 69.8 / 52.3 | open source |
| `Skywork-13B` | Base / Chat / Math / MM | 13B | 通用 | open source (商用免申請) |
| `Skywork-MoE` | 稀疏 MoE | ~146B active / 2T total | 大型推理 | open source (**需 8×4090**) |
| `SkyReels-V3` | Video gen | multimodal | text-to-video | open source (2026-01) |
| `Skyo` | Voice assistant | n/a | real-time voice | 商用 SaaS |
| `Skywork-Reward-V2` | Reward model | 8B / 4B / 1.5B | RLHF / 評分 | open source |
| `Skywork.ai workspace` | SaaS suite | n/a | doc / slide / code | $19.99/mo Individual, Enterprise custom |

**Benchmark (未實測, web 引用)**:
- `Skywork-OR1-32B`: AIME24 = **82.2**, AIME25 = **73.3**, LiveCodeBench (2024-08 ~ 2025-02) = **63.0** (超越 DeepSeek-R1 + Qwen3-32B in math)
- `Skywork-OR1-Math-7B`: AIME24 = **69.8**, AIME25 = **52.3** (同 size 最強)
- `Skywork-Reward-V2-Llama-3.1-8B`: RewardBench average **#1** (8 個 variant 都有出)
- `Skywork-Reward-V2-Llama-3.1-8B-40M`: 26M preference pairs curated via human-LLM synergy pipeline
- `Skywork-Reward-V2-Qwen3-4B`: 4B variant for resource-constrained

**Self-host 硬件需求 (llama.cpp / vLLM)**:
- 13B Q4_K_M: ~**8-10 GB VRAM** (消費級 RTX 4080/3090)
- 7B Q4_K_M: ~**4-6 GB VRAM** (RTX 3060 都得)
- 32B Q4_K_M: ~**20 GB VRAM** (RTX 4090)
- 70B Q4_K_M: ~**42 GB VRAM** (1× A100 80G / 2× RTX 4090)
- 8B reward model Q4: ~**5 GB VRAM**
- vLLM PagedAttention: fragmentation 損耗可達 20-30%，要預 buffer
- Tensor parallel (multi-GPU): PCIe bandwidth 限速，~0.7× scaling，48GB combined 解鎖 70B Q4

**我哋部機 viability check** (2 cores + 7.4GB RAM, **冇 GPU**):
- ❌ 全部 model 都需要 VRAM，我哋冇
- ⚠️ **CPU-only inference** (llama.cpp CPU mode): 13B Q4 估 1-3 tok/s (極慢), 7B 估 3-8 tok/s
- ⚠️ Memory swap 風險: 13B Q4 weights ~8GB, 加 KV cache + overhead 隨時 OOM
- ⚠️ Inference 同網絡 IO 撞 RAM，會拖慢其他 process (yt-dlp / whisper / PDF render)
- **Verdict**: **唔建議** self-host 喺我哋部機。用 VPS (RunPod / Vast.ai / Lambda Labs 1× RTX 4090 ~ $0.5/hr) 比較實際

**API 接入 4 條路**:
1. **Skywork 自家 API**: 直接註冊 `skywork.ai` developer account → API key
   - 預估定價: 對標 Anthropic / OpenAI tier (individual 之外 enterprise custom)
2. **APIFree.ai aggregator** (`apifree.ai`): OpenAI-compatible, single endpoint 接入 GPT / Claude / Gemini / Skywork 一齊
   - 收費模型: "routing free, pay for features"; Hacker tier free forever (零 markup); Team $499/mo; Enterprise custom
   - 用法: `pip install openai`, base_url 改 APIFree endpoint, 直接 OpenAI SDK call
3. **本地自托管 llama.cpp**: 完全 free, 但要 GPU VPS
4. **HuggingFace Inference API**: Skywork 全部 weights 上 HF，可付費用 HF Inference Endpoint

**中港 access 限制** (potential pitfall):
- 內地 model → 唔同 hosting 服務可能有 geo-block
- 中國 IP 出 OpenAI/Anthropic 受限，我哋 s4.hk38.ltip.xyz proxy 已經驗證可過 YouTube，但唔知 APIFree / Skywork 端點
- **Caveat**: 真正接入前先用 curl 試 endpoint reachability

**Reference 用途** (per user #6263):
- **Fallback reasoning layer**: 取代 blocked Gemini API (我哋 MEMORY lesson 已知 `API_KEY_SERVICE_BLOCKED`)
- **Reward model audit**: Skywork-Reward-V2 plug 入 PDF / transcript quality scoring (我哋 PDF 質素目前靠 manual review, 8B reward model 可 automate 一致性 check)
- **Video gen future**: SkyReels-V3 太重，但 reference 我哋 video pipeline 嘅 reference list
- **教訓 reference**: Skywork-OR1 "RL for reasoning" 嘅 case study 可 reference 我哋未來 LLM-related debug

**Sources** (untrusted, web snippets only, **未實測**):
- https://github.com/SkyworkAI
- https://github.com/SkyworkAI/Skywork-OR1
- https://github.com/SkyworkAI/Skywork-Reward-V2
- https://arxiv.org/html/2505.22312v1 (Skywork-OR1 technical report)
- https://arxiv.org/pdf/2507.01352 (Skywork-Reward-V2 paper)
- https://huggingface.co/Skywork (40+ models)
- https://skywork.ai/skypage/en/skywork-ai-copilot-pricing-2026/2034521488383823872
- https://news.aibase.com/news/25082 (SkyReels-V3 release)
- https://www.apifree.ai/model/skywork-ai/skyclaw-v1?tab=api
- https://localllm.in/blog/llamacpp-vram-requirements-for-local-llms (VRAM math)
- https://www.sitepoint.com/vram-requirements-70b-models-16gb-gpu-minimum-2026/
- https://localaimaster.com/blog/vram-requirements-2026

**Net-zero**: 1 reference entry, 0 deploy, 0 paid commitment, 4 個 decision point (self-host / API / APIFree / HF Inference) 已 audit


### 2026-07-16 (deep dive lesson)
21. **🔴 慎用 multi-choice 反訪問 scope disambig** (user #6271 即時 reject)
    - 之前 pattern: user 含糊 request → 我放 multi-choice button 問揀 scope
    - 已被 reject 兩次 (#6271 「咩來 你想做乜」, 之前一次 "繼續繼續咩事咩事")
    - **Lesson**: 當 user 講「多啲」、「詳細啲」、「全面啲」呢類**加 depth 嘅 request**，**直接做 E = 全部 deep dive**，唔好又問 scope
    - **Trigger 條件**: 
      - ✅ 反訪問適用: 完全 zero-info request, 無 evidence, 真係需要 disambig (例如 #7596 「檢查 Zeabur TG」)
      - ❌ 反訪問 overkill: 加 depth / 詳細 / 全面 / deep dive → 直接執行 full scope
    - **Net-zero check**: multi-choice button = outbound overhead, 浪費 user round-trip, 浪費 token

### 2026-07-16 (deep dive lesson)
21. **🔴 慎用 multi-choice 反訪問 scope disambig** (user #6271 即時 reject)
    - 之前 pattern: user 含糊 request → 我放 multi-choice button 問揀 scope
    - 已被 reject 兩次 (#6271 「咩來 你想做乜」, 之前一次 #7656 「繼續繼續咩事咩事」)
    - **Lesson**: 當 user 講「多啲」、「詳細啲」、「全面啲」呢類**加 depth 嘅 request**，**直接做 E = 全部 deep dive**，唔好又問 scope
    - **Trigger 條件**:
      - ✅ 反訪問適用: 完全 zero-info request, 無 evidence, 真係需要 disambig (例如 #7596「檢查 Zeabur TG」)
      - ❌ 反訪問 overkill: 加 depth / 詳細 / 全面 / deep dive → 直接執行 full scope
    - **Net-zero check**: multi-choice button = outbound overhead, 浪費 user round-trip, 浪費 token

### 2026-07-16 (qdZ01t-dqw8 階段新 lessons)
22. **🔴 PDF render_summary_pdf.py 嘅 header hard-coded 喺 `_1IM9ZpmEWc` 入面** (qdZ01t-dqw8 階段發現)
    - `header_footer()` function 入面個 `"Finding Your Unknowns — ..."` 字串係 hard-coded
    - Generic render 別嘅 PDF 時 header 會出錯
    - **Workaround**: 在 caller script 入面 override `onFirstPage` / `onLaterPages` 用 custom header lambda (qdZ01t-dqw8 用咗呢個 pattern)
    - **Net-zero fix**: 未來 generic renderer (`render_generic_summary.py`) 應該將 header text 做 CLI arg
23. **🔴 YouTube download 撞 bot detection 需要 JS runtime** (qdZ01t-dqw8 階段)
    - yt-dlp deprecate 咗 without JS runtime extract — `WARNING: [youtube] No supported JavaScript runtime could be found`
    - 撞 YouTube "Sign in to confirm you're not a bot" → audio download fail
    - **Solution**: 加 `--js-runtimes node` flag (我哋部機有 Node v22.22.2)
    - 同 `--proxy socks5://utl:mhd@s4.hk38.ltip.xyz:20105` **一齊用** 必需 — direct 連 YouTube IP 已 block
    - **Trigger**: 任何 YT video fetch 都應該 by default 用：`yt-dlp --proxy socks5://... --js-runtimes node ...`
