#!/usr/bin/env python3
"""
Smart Image Generator — Zhi API primary (2026-07-28: Aetheracode removed)
Usage: smart_image_gen.py <prompt> [size] [quality] [model] [ref_image] [provider]
Provider: auto | zhi
"""

import sys
import json
import subprocess
import os
import base64
from datetime import datetime

PROMPT    = sys.argv[1] if len(sys.argv) > 1 else ""
SIZE      = sys.argv[2] if len(sys.argv) > 2 else "1024x1024"
QUALITY   = sys.argv[3] if len(sys.argv) > 3 else "high"
MODEL     = sys.argv[4] if len(sys.argv) > 4 else "gpt-image-2"
REF_IMG   = sys.argv[5] if len(sys.argv) > 5 else ""
PROVIDER  = sys.argv[6] if len(sys.argv) > 6 else "auto"

MAX_RETRIES = 4

# ── Keys ──────────────────────────────────────────────────────────

def get_zhi_key():
    with open("/home/ubuntu/.openclaw/agents/main/agent/models.json") as f:
        d = json.load(f)
    providers = d.get("providers", {})
    zhi = providers.get("zhi-api", {})
    return zhi.get("apiKey", "")

ZHI_KEY = get_zhi_key()

# ── Output ────────────────────────────────────────────────────────

DATE_DIR = datetime.now().strftime("%Y-%m-%d")
OUT_DIR  = f"/home/ubuntu/.openclaw/workspace/images/{DATE_DIR}"
os.makedirs(OUT_DIR, exist_ok=True)

# ── Build payload ────────────────────────────────────────────────

def build_payload(model, prompt, size, quality, ref_path=None):
    d = {
        "model": model,
        "prompt": prompt,
        "size": size,
        "quality": quality,
    }
    if ref_path and os.path.isfile(ref_path):
        with open(ref_path, "rb") as f:
            b64 = base64.b64encode(f.read()).decode()
        d["image"] = f"data:image/jpeg;base64,{b64}"
    return json.dumps(d)

# ── API call ─────────────────────────────────────────────────────

QUOTA_ERRORS = {"INSUFFICIENT_BALANCE", "quota_exceeded", "rate_limit_exceeded"}

def call_api(url, key, payload_path, timeout=180):
    print(f"🌐 Calling {url}...")
    r = subprocess.run(
        ["curl", "-s", "--max-time", str(timeout),
         "-X", "POST", url,
         "-H", "Content-Type: application/json",
         "-H", f"Authorization: Bearer {key}",
         "-d", f"@{payload_path}"],
        capture_output=True, text=True
    )
    if not r.stdout:
        return {"error": {"code": "EMPTY_RESPONSE", "message": "No response from API"}}
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return {"error": {"code": "INVALID_JSON", "message": r.stdout[:300]}}

# Returns: (success, failover, fatal, provider, out_path)
def try_generate(provider_name, url, key, timeout=180):
    payload_path = f"/tmp/img_payload_{provider_name}.json"
    payload = build_payload(MODEL, PROMPT, SIZE, QUALITY, REF_IMG if provider_name=="aetheracode" else REF_IMG)
    with open(payload_path, "w") as f:
        f.write(payload)
    resp = call_api(url, key, payload_path, timeout)

    # Check error
    err = resp.get("error", {})
    code = err.get("code", "") if err else ""

    if code in QUOTA_ERRORS:
        print(f"⚠️  {provider_name} quota error: {code}", file=sys.stderr)
        return False, True, False, provider_name, None   # (ok, failover, fatal, prov, path)

    if code == "INVALID_API_KEY":
        print(f"🚫 {provider_name} invalid API key — fatal", file=sys.stderr)
        return False, False, True, provider_name, None

    if err:
        msg = err.get("message", str(err))
        print(f"❌ {provider_name} error: {msg}", file=sys.stderr)
        return False, False, False, provider_name, None

    # Success
    b64 = resp.get("data", [{}])[0].get("b64_json")
    if not b64:
        print(f"❌ {provider_name} — no b64_json in response", file=sys.stderr)
        return False, False, False, provider_name, None

    out = os.path.join(OUT_DIR, f"{provider_name}_{int(datetime.now().timestamp())}.png")
    with open(out, "wb") as f:
        f.write(base64.b64decode(b64))

    size = os.path.getsize(out)
    print(f"✅ SUCCESS: {out} ({size/1024/1024:.1f} MB) | Provider: {provider_name}")
    return True, False, False, provider_name, out

# ── Main ──────────────────────────────────────────────────────────

if not PROMPT:
    print("ERROR: prompt required", file=sys.stderr)
    print("Usage: smart_image_gen.py <prompt> [size] [quality] [model] [ref_image] [provider]", file=sys.stderr)
    sys.exit(1)

print(f"Prompt: {PROMPT}")
if REF_IMG:
    print(f"Ref image: {REF_IMG}")
print(f"Model: {MODEL} | Size: {SIZE} | Quality: {QUALITY}")
print(f"Provider mode: {PROVIDER}")
print()

if PROVIDER == "zhi":
    ok, failover, fatal, prov, path = try_generate(
        "zhi",
        "https://zhi-api.com/v1/images/generations",
        ZHI_KEY, 300)
    sys.exit(0 if ok else 1)

# Auto mode = Zhi only (2026-07-28)
ok, _, fatal, prov, path = try_generate(
    "zhi",
    "https://zhi-api.com/v1/images/generations",
    ZHI_KEY, 300)
sys.exit(0 if ok else 1)
