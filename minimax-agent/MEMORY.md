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
- **Anti-bot**: `yt-dlp --proxy socks5://utl:mhd@s4.hk38.ltip.xyz:20105 --js-runtimes node`

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
export all_proxy="socks5://utl:mhd@s4.hk38.ltip.xyz:20105"
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
export all_proxy="socks5://utl:mhd@s4.hk38.ltip.xyz:20105"
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

### 🔴 Critical lessons（完整 story 見 daily log）
- Lesson #15: Workspace path outbound 必須 OpenClaw workspace 否則 `OutboundDeliveryError`
- Lesson #16: Workspace wipe confirmed，script 必須 commit 入 workspace git
- Lesson #17: Noto CJK font (CFF/PostScript) 唔可以用 reportlab 直接 load → 用 STSong-Light
- Lesson #18: YT 短片 (< 5 min) zh-Hant 撞 429 → 只用英文 + 自己 distill
- Lesson #22: PDF render header hard-coded — caller 需 override `onFirstPage`/`onLaterPages`
- Lesson #23: YT download 撞 bot → 必須加 `--js-runtimes node`
- Lesson #24: Inbound metadata audit — reply_to_id / body vs memory mismatch 時先 audit 再回覆
- Lesson #25: 唔好 overshoot call tool — 冇 goal 唔 call update_goal

## Promoted From Short-Term Memory (2026-07-27)

<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:26:42 -->
- `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/_1IM9ZpmEWc.en-US.vtt` (10KB, raw) - `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/scripts/dedupe_vtt.py` (reusable) - `memory/2026-07-15/yt-transcripts/_1IM9ZpmEWc/scripts/render_summary_pdf.py` (reusable, generic zh-Hant PDF renderer) ### Key insights (跨 MEMORY 整合) - **Finding Your Unknowns 直接 map MEMORY insight-006 (Fable 5 rules)**: 6 條 rule 入面 3 條對位 — WHY / Negative prompt / 唔好 over-plan。PDF sec 8 已 explicit 講呢個 cross-ref。 - **同 14 lessons 對位**: lesson #14 (silent reply stream corruption)、lesson #15 (outbound workspace path)、lesson #17 (CID font)、lesson #18 (短片 429) 全部 present 喺今次... [score=0.926 recalls=4 avg=1.000 source=memory/2026-07-15.md:26-42]
