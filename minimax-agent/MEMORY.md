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

## Promoted From Short-Term Memory (2026-07-26)

<!-- openclaw-memory-promotion:memory:memory/2026-07-09.md:159:181 -->
- 3. **test-e2e-fSjdYzrFvA.sh** — future sessions can regression at 5 sec cost 4. **YouTube 429 throttling** — 同一片多次 hit 會限速；個 VTT count relaxed to ≥1 ## 08:32 — Round 7: 整理 MEMORY 消除混亂 (用戶 push: 「將會混亂你 影響你的資料 刪去 或者多加整理」) ### 用戶 push 「將會混亂你 影響你的資料 刪去 或者多加整理 唔好入誤區」 — 識別混亂根源, 清理。 ### 識別到嘅 6 個混亂點 1. **A** Cloud VM header 仍寫「YouTube 一睇就 block」 — contradict verified fact 2. **B** `youtube-transcript-api` 標 cloud IP 攔截 — 從未真試, 同今日 evidence inconsistent 3. **C** 「Anti-bot」section 同 「Workflow Rules」section 兩個地方寫同一個反-claim 4. **D** Reference test "3× .vtt" 同 test 結果 "1 VTT (en only, 429)" 相矛盾 5.... [score=1.000 recalls=12 avg=1.000 source=memory/2026-07-09.md:159-181]
<!-- openclaw-memory-promotion:memory:memory/2026-07-09.md:19:41 -->
- ## Session 02:30 GMT+8 (cont.) — Arslan asked: 幫我睇下可唔可以再優化, 在意見及Debug上更嚴謹, 係呢啲workflow有冇miss地方, 正常做法等等, 即係睇下個memory 要唔要整理 清理下 ### Phase 1-2 audit: 12 debug-posture issues found | # | File | Issue | |---|------|-------| | A1 | `yt-subs.sh` | `set -e` + sub-capture 用 bad pattern, dispatch fire step1 twice | | A2 | `yt-subs.sh` | step2a fail 即落 step2b, .m4a missing → ffmpeg fail (no guard) | | A3 | `yt-subs.sh` | "return no subtitles" 同 "error" logic 混淆 | | A4 | `lib-config.sh` | LANG_DEFAULT 唔 mirror YouTube format | | A5 | sub-steps | 冇 `set -u`, `pipefail`, `trap` | | A6 | `step2b` | pipe + `tail` 撞 `set -e` 失效 | | A7 | `step2c` |... [score=1.000 recalls=8 avg=1.000 source=memory/2026-07-09.md:19-41]
<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:93:126 -->
- Section: "Unknowns-First Protocol" - Source: insight-007 (Finding Your Unknowns) - 3-step mandatory pre-task: blind spot scan → discovery method → act - 4-type framework mandatory for complex debug - Reference path: memory/<YYYY-MM-DD>/debug-cases/case-NN-* **Net-zero**: 1 new section, 0 noise scripts added, audit trail complete --- ## 01:43 GMT+8 — Skywork research (#6263, user choice D) User: "上網研究下skywork係乜？ 背景？ 收費？ 可以用自家api模型？" User follow-up: "D" (Reference 用, no deploy) **Discovery**: Skywork = Kunlun Wanwei 昆仑万維 / Kunlun Tech, 內地 top LLM team **Background**: 2023-10 開源 Skywork-13B 起家，~400M MOU，港股 **Products**: Skywork-OR1 /... [score=1.000 recalls=7 avg=1.000 source=memory/2026-07-15.md:93-126]
<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:123:141 -->
- User: "多啲 詳細的" → 要 deep dive, 唔係又再 disambiguate **Lesson learnt (NET-ZERO FAIL)**: 第一次 (#6270) 我又放 multi-choice button 反訪問 scope — 被 user #6271 "咩來 你想做乜" 即時 reject。即知 **multi-choice 反訪問 pattern 太煩，要慎用**。 **Final deep dive scope (E = 全部都要)**: - 完整 8 個產品線 table + size + license - Benchmark (OR1-32B / OR1-Math-7B / Reward-V2) - Self-host VRAM 完整 breakdown (13B/7B/32B/70B) - 我哋部機 viability check (CPU-only 不建議) - API 接入 4 條路 (Skywork / APIFree / llama.cpp / HF Inference) - 中港 access pitfall - 5 個 reference use cases - 12 個 source URLs **MEMORY**: Skywork section 由 24 行 → 49 行 (rich detail) **Lesson #21 (NEW)**: multi-choice 反訪問 scope... [score=0.918 recalls=5 avg=1.000 source=memory/2026-07-15.md:123-141]
<!-- openclaw-memory-promotion:memory:memory/2026-07-09.md:1:25 -->
- # 2026-07-09 Session Log ## Session 02:11 GMT+8 — Arslan asked: 開了新session, 你先檢查一下, 再測試個script 是否完成 ### Phase 1-3: fact-check + bug fixes - 7 split files verify (lib-config/step1/step2a/step2b/step2c/poll/dispatcher) - Bug #1 #2 #3 #4 + #5 (--cookies) fixed - Demo `cBgT0PG4JkM` + `5XI5bn_7tJw` 都撞 YouTube innerTube anti-bot (exit 2, 唔 hang) - Option B: whisper STT run 用 `audio-hA_XnzB1Ef8.m4a` → 211 segs / 19075 chars / 213.9s ✅ - Option C: commit pair URLs, host workspace 喺 02:25 wipe 過一次, 我所有 user-written file lost → 重新 baseline commit ## Session 02:30 GMT+8 — Arslan 問: 你呢家做任務分析詳盡左 結構性左 原因係？ Honest meta-analysis: 結構性高嘅主因係 1.... [score=0.900 recalls=4 avg=1.000 source=memory/2026-07-09.md:1-25]
<!-- openclaw-memory-promotion:memory:memory/2026-07-15.md:1:30 -->
- # 2026-07-15 — Daily Log ## 23:48-23:55 GMT+8 — YT transcript pipeline run #8 User send: `https://youtu.be/_1IM9ZpmEWc?si=Y3oTyImqqvT4XIly` **Channel**: Paula 寶拉 **Title**: Anthropic 大神的用 AI 心法：先畫出你的知識地圖 **Duration**: 6:08 (短片) **Upload**: 2026-07-12 **Source**: Thariq Shihipar《Finding Your Unknowns》 ### Pipeline execution 1. **yt-dlp via SOCKS5**: en-US.vtt 10KB / 114 cues ✅, en-zh-TW 429 (短片預期內, lesson #18) 2. **dedupe**: 114 → 114 (no-op, line-per-cue format, 非 rolling-window pattern) 3.... [score=0.821 recalls=3 avg=1.000 source=memory/2026-07-15.md:1-30]
