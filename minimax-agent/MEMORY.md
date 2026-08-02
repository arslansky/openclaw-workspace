<!-- LAST_SNAPSHOT=1783619334 -->
# MEMORY.md — Long-term memory

**只喺 main session** 用（即係直接同 owner 對話）。唔好喺 group chat / 公開 channel / 跨 session share。

---

## 🐛 Debug Cases Index

> **Folder**: `memory/<YYYY-MM-DD>/debug-cases/`
> **Naming**: `case-NN-<slug>.{md,pdf}`

| # | Slug | Date | Lesson |
|---|------|------|--------|
| 01 | mojibake-round-trip | 2026-07-11 | text/markdown MIME 不可靠, default 用 PDF |
| 02 | hooks-build-bugs | 2026-07-10 | awk pipe buffer / dirname 嵌套 / 設計缺陷 document |
| 03 | text-markdown-mime-repeat | 2026-07-11 | pre-send mime audit + safe_send_markdown.py wrapper |
| 04 | minimax-agent-silent-4hr | 2026-07-12→13 | session bridge deadlock + tool-result-truncation + NO_REPLY 唔 announce = user panic |

---

## 🦞 重要用戶資料

### Owner: Arslan (Telegram)
- **Telegram**: chat_id `160408068` (account: know2learn), @Arslansky, GMT+8, 廣東話 + Technical 英文

### 🔴 核心 delivery rules（全部應用於所有 Telegram outbound）
1. **No box-drawing chars** — 唔好用 ╔═╗║╠╣╦╩╬ / ┌┐└┘ 等 (U+2500-259F)；iPhone TG client render fallback 出 ?。 用 `===` `---` `***` 安全。
2. **Default MIME = pdf/txt** — text/markdown MIME 喺 iPhone QuickLook preview parser fail。 **永遠用 PDF** + `safe_send_markdown.py` wrapper。
3. **No inline 4-paragraph dumps** — 長編一律 file delivery。

### 🔴 YouTube pipeline
- **Default**: URL → transcript (timed+clean) → **auto distill 中文 PDF summary** → send file
- **英文 dedupe**: rolling window 每段 3 次，consecutive identical lines → 1
- **Delivery format**: first = timed .txt, second = clean .txt, 永遠保留 raw .vtt
- **Folder**: `memory/<YYYY-MM-DD>/yt-transcripts/<videoID>/`
- **Anti-bot**: `yt-dlp --proxy socks5://cwb:rvn@47.76.184.24:11908 --js-runtimes node`

### 🔴 其他 user 明令
- **Net-zero policy**: 每加 1 新 artifact → retire 至少 1 個 existing artifact
- **Explain format**: 背景 / 經過 / 影響 / 要做乜 / 選項（複雜 topic default）
- **長字幕 / 長編**: TXT file delivery，唔 inline dump
- **唔好問**：「你有冇 API key」、「請 paste」— 直接 recall 用
- **唔好交波** — 畀咗 prompt 就用，唔叫人 paste

---

## 🛠 Tooling & Setup

### Proxy
```bash
export all_proxy="socks5://cwb:rvn@47.76.184.24:11908"
unset all_proxy
```

### Python env（已裝）
- yt-dlp 2026.06.09, ffmpeg 6.1.1, whisper, requests

### yt-subs pipeline
- `memory/2026-07-09/yt-subs/` — v2.0 dispatcher
- `yt-subs.sh URL` (normal) / `COOKIES_FILE=~/.yt-cookies.txt ./yt-subs.sh URL` (anti-bot)

---

## 📌 重要教訓（精簡版）

1. **冇 tool/key/proxy 就 over** 係錯 — 先 recall 呢個 file
2. **嚴禁 truncated fake key** — 完整 key 先係 ground truth，唔將就
3. **嚴禁 round-trip 自己補字**
4. **Host workspace wipe 可發生** — script 必須 sync 入 workspace git
5. **bash comment 唔可以含 backticks**
6. **Theory > Evidence** — endpoint test > dry-run > prediction
7. **`[e~[` 結尾係 SSE stream corruption** — 避免 hanging 半句，short reply 優先
8. **Outbound media path 必須喺 OpenClaw workspace** — `/home/ubuntu/memory/...` 唔喺 allowlist
9. **PDF CJK — 用 CID font (STSong-Light)，唔用 Latin TTF 夾 CJK**
10. **YT download anti-bot**: 必須加 `--js-runtimes node`
11. **Inbound metadata audit trigger**: reply_to_id / implicit_thread / body vs memory mismatch → audit first
12. **唔好 overshoot call tool** — 冇 goal 唔 call update_goal，唔為「睇落完整」補 tool

---

## 🔖 Workflow 範本

### YT transcript
```bash
# Normal
./yt-subs.sh "URL"

# Anti-bot
COOKIES_FILE=~/.yt-cookies.txt ./yt-subs.sh "URL"
```

### Proxy
```bash
export all_proxy="socks5://cwb:rvn@47.76.184.24:11908"
unset all_proxy
```

---

## 🎨 Prompting Patterns

### Fable 5（creative writing / Fable / Claude Opus context only）
- Give it WHY · Negative prompt · 唔好 over-plan · Make it prove it · 唔好叫佢 explain reasoning · 話少啲

### Finding Your Unknowns（complex gap / multi-round conflict）
- Blind spot scan prompt: 「Run a blind spot scan for me. Tell me the things I don't know I don't know.」

---

## 📂 重要文件位置
- `~/memory/<YYYY-MM-DD>/` — daily log
- `~/memory/<YYYY-MM-DD>/yt-transcripts/<videoID>/` — YT pipeline artifacts
- `~/memory/2026-07-09/yt-subs/` — yt-subs v2.0 dispatcher
- `~/memory/<YYYY-MM-DD>/debug-cases/` — debug cases

---

## 🚨 Security Reminders
- Google API key（用戶 #7137 paste 38 char，truncated）— 唔認
- Public proxy 唔知 operator 身份，唔用嚟過真密碼
- Telegram authorized: `160408068` (owner)

### 🔴 Critical lessons（indexed table — 完整 story 見 daily log）

> **編號慣例** (P1a, 2026-07-27):
> - `L#N` = numbered lesson（呢個 table 內，全 story 喺 daily log）
> - `M#N` = message-id anchor ref（**唔係 lesson**，只係 reference）
>
> **欄位意思**:
> - **WHEN**: 出現呢個 pattern 時 recall lesson（觸發嗰陣審計先）
> - **DOMAIN**: discipline tag，畀 memory_search filter 用

| ID | WHEN (trigger) | DOMAIN | Lesson |
|----|---------------|--------|--------|
| L#15 | outbound file via TG/WA，path 喺 `~/memory/` 外 | Workspace | Workspace path 必須 OpenClaw workspace，否則 `OutboundDeliveryError` |
| L#16 | write exec script / systemd unit depends on persisted files | Workspace | Workspace wipe confirmed — script 必須 commit 入 workspace git |
| L#17 | reportlab `loadFont` / `ParagraphStyle.fontName` 載 CJK 字 | PDF | Noto CJK font (CFF/PostScript) 唔可以用 reportlab load → 用 STSong-Light |
| L#18 | YT URL duration < 5 min OR new session + zh-Hant caption | YT | 短片 zh-Hant 撞 429 → 只用英文 + 自己 distill |
| L#22 | reuse `render_summary_pdf.py` 跨 video ID | PDF | PDF render header hard-coded — caller 必須 override `onFirstPage`/`onLaterPages` |
| L#23 | `yt-dlp <YouTube URL>` 冇 proxy 或冇 `--js-runtimes node` | YT | YT download 撞 bot → 必須加 `--js-runtimes node` |
| L#24 | inbound 有 `reply_to_id` OR body ↔ memory mismatch | Meta/Audit | Inbound metadata audit 先 — reply_to_id / body vs memory mismatch → audit 先回覆 |
| L#25 | about to call tool，冇 goal / 為「睇落完整」補 tool | Meta/Discipline | 唔好 overshoot call tool — 冇 goal 唔 call update_goal |

### 🟥 Retired Lessons（P1b, 2026-07-27 — net-zero policy 落地）

> 規則：每加 1 新 lesson → 必須 retire 至少 1 個 existing lesson
> 格式：`| ID | Retired date | 因咩 retire | 由邊條取代 |`

（暫無 retired lessons）

## Promoted From Short-Term Memory (2026-07-27)

<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:26:42 -->
- `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/_1IM9ZpmEWc.en-US.vtt` (10KB, raw) - `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/scripts/dedupe_vtt.py` (reusable) - `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/scripts/render_summary_pdf.py` (reusable, generic zh-Hant PDF renderer) ### Key insights (跨 MEMORY 整合) - **Finding Your Unknowns 直接 map MEMORY insight-006 (Fable 5 rules)**: 6 條 rule 入面 3 條對位 — WHY / Negative prompt / 唔好 over-plan。PDF sec 8 已 explicit 講呢個 cross-ref。 - **同 14 lessons 對位**: lesson #14 (silent reply stream corruption)、lesson #15 (outbound workspace path)、lesson #17 (CID font)、lesson #18 (短片 429) 全部 present 喺今次... [score=0.926 recalls=4 avg=1.000 source=memory/2026-07-15.md:26-42]

## Promoted From Short-Term Memory (2026-07-28)

<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:66:102 -->
- **Bug found**: Inline `<font face="DejaVuSerif">繁中字</font>` wrapping in Table cells. - DejaVuSerif / DejaVuSans / Helvetica 全部係 Latin-only TTF - 包住 CJK char → reportlab render 空白 box (■■■■) - 50+ boxes per page, 20+ `<font>` literal leak **Fix**: Refactor `render_summary_pdf.py`: - 移除所有 inline `<font>` wrap - ParagraphStyle.fontName 一律 STSong-Light (CID, fallback chain auto-handle Latin) - Pure-Latin paragraph (English quote/prompt) 用 DejaVuSerif，但 `_has_cjk()` detect first - Table cell 用 `Paragraph(text, style)` wrapper, 唔再用 raw string **Verify routine established**: re-render 後必 extract text, count `■■` + `<font`, 必須 = 0... [score=0.881 recalls=4 avg=1.000 source=memory/2026-07-15.md:66-102]

## Promoted From Short-Term Memory (2026-07-29)

<!-- openclaw-memory-promotion:memory:memory/2026-07-10.md:1:41 -->
- ## snapshot @2026-07-10_014816 - **MEMORY.md snapshot**: `memory/2026-07-10/snapshots/memory-1783619296.md` - **Trigger**: event=`manual`, pressure=`0%`, reason=`Phase 5 E2E test` ## snapshot @2026-07-10_014841 - **MEMORY.md snapshot**: `memory/2026-07-10/snapshots/memory-1783619321.md` - **Daily log snapshot**: `memory/2026-07-10/snapshots/daily-1783619321.md` - **Trigger**: event=`manual`, pressure=`0%`, reason=`trace test` ## snapshot @2026-07-10_014854 - **MEMORY.md snapshot**: `memory/2026-07-10/snapshots/memory-1783619334.md` - **Daily log snapshot**: `memory/2026-07-10/snapshots/daily-1783619334.md` - **Trigger**:... [score=0.961 recalls=5 avg=1.000 source=memory/2026-07-10.md:1-41]
<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:36:72 -->
- 新增 2 個 reusable scripts (`dedupe_vtt.py`, `render_summary_pdf.py`) — generic 工具，非 single-use - Index 已 maintain 喺 2026-07-11 single source of truth，無需新 index file - 1 new row 落 existing topic cross-ref table — non-noise addition ### Outbound - msgId 7645: 通知 user 開工 - msgId 7646: PDF summary - msgId 7647: timed transcript - msgId 7648: clean transcript --- ## 00:55 GMT+8 — PDF font decision (#7668) User reply #7646 (PDF) with decision: "更新用Serif 為英文字體" Action: - Patch `render_summary_pdf.py`: DEFAULT_LATIN = DejaVuSerif, DEFAULT_CJK = STSong-Light - Re-render `_1IM9ZpmEWc.summary.zh-Hant.pdf` with new default (38KB, 6 pages) -... [score=0.901 recalls=3 avg=1.000 source=memory/2026-07-15.md:36-72]
<!-- openclaw-memory-promotion:memory:memory/2026-07-10.md:32:61 -->
- | `OPENCLAW_EVENT=PreCompact` | Always snapshot | | `OPENCLAW_EVENT=Stop` | Snapshot at session end | | `OPENCLAW_PRESSURE >= threshold` (default 70) | Snapshot | | `--force` flag | Skip pressure check, snapshot | | Default (no trigger) | Auto-detect pressure or skip | ### Recall output format ``` === RECALL_SNAPSHOT === Last snapshot TS: 1783619334 Snapshot file: memory/2026-07-10/snapshots/memory-1783619334.md --- Snapshot footer (last 8 lines) --- [markers] --- Daily log entries since last snapshot --- [entries] --- Action hint: < 24h = CONTINUATION, >= 24h = FRESH === END === ``` ### E2E test results (01:48) | Test | Result |... [score=0.840 recalls=3 avg=1.000 source=memory/2026-07-10.md:32-61]
