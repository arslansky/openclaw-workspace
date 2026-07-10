#!/usr/bin/env python3
"""Cleanup SRT + summary using MiniMax M2.7 via anthropic-messages API."""
import json, time, httpx, os, sys

with open("/home/ubuntu/.openclaw/openclaw.json") as f:
    cfg = json.load(f)
mm = cfg["models"]["providers"]["minimax"]
KEY = mm["apiKey"]
BASE = mm["baseUrl"]   # https://api.minimax.io/anthropic
MODEL = "MiniMax-M2.7"

SRT = "/tmp/AGT-stt/AGTAyXbpO64.srt"
OUT_DIR = "/tmp/AGT-stt"
LOG = "/tmp/AGT-cleanup.log"

def log(m):
    with open(LOG, "a") as f:
        f.write(f"[{time.strftime('%H:%M:%S')}] {m}\n"); f.flush()

log(f"using minimax, model={MODEL}")

with open(SRT) as f:
    srt = f.read()
log(f"loaded srt {len(srt)} chars")

PASS_A = (
    "清理 SRT 字幕（廣東話 / 普通話 / 英文混合 tutorial 影片）：\n"
    "1. 修正常見工具 / AI 模型 / 平台 / 品牌名。\n"
    "2. 刪除連續重複字串 / Whisper hallucination loop。\n"
    "3. 修正常見粵普通 / 簡繁混雜。\n"
    "4. 保留時間碼同 segment 編號。\n"
    "5. 原文語言保留 — 唔好翻譯。\n"
    "6. 輸出純 SRT 格式。\n"
)

PASS_B = """基於以下清理後嘅字幕，寫繁體中文摘要報告：
- 開頭：1 段簡介（邊條片 / 主題 / demo 內容）
- 條目：6-10 點 bullet，按教學流程順序
- 結尾：1 段結論（建議觀眾對象、應用場景）
- 長度：600-900 字
- 用繁體中文 + 技術英文詞
- 唔好用 emoji
"""

def get_text(j):
    """Extract text from anthropic response content (may have thinking blocks)."""
    for block in reversed(j["content"]):
        if block["type"] == "text":
            return block["text"]
    return ""

def call_minimax(system_prompt, user_msg, max_tok=16000, temp=0.2):
    payload = {
        "model": MODEL,
        "max_tokens": max_tok,
        "system": system_prompt,
        "messages": [{"role": "user", "content": user_msg}],
        "temperature": temp,
    }
    r = httpx.post(f"{BASE}/v1/messages",
        headers={
            "x-api-key": KEY,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=600.0)
    r.raise_for_status()
    j = r.json()
    return get_text(j)

t0 = time.time()
log("pass A: dedup srt")
try:
    clean = call_minimax(PASS_A, srt, 16000, 0.2)
except Exception as e:
    log(f"pass A ERR {e}")
    sys.exit(1)

log(f"pass A {time.time()-t0:.1f}s, {len(clean)} chars")
with open(f"{OUT_DIR}/AGTAyXbpO64.clean.srt", "w") as f:
    f.write(clean)

log("pass B: 中文 summary")
try:
    summary = call_minimax(PASS_B, clean, 3000, 0.3)
except Exception as e:
    log(f"pass B ERR {e}")
    sys.exit(1)

log(f"pass B done, {len(summary)} chars")
with open(f"{OUT_DIR}/AGTAyXbpO64.summary.zh.md", "w") as f:
    f.write(summary)
log(f"TOTAL wall {time.time()-t0:.1f}s")
print("DONE")
print(f"clean.srt: {len(clean)} chars")
print(f"summary: {len(summary)} chars")
