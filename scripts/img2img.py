#!/usr/bin/env python3
import sqlite3, json, urllib.request, urllib.error, base64, sys, os, time

IMG_PATH = sys.argv[1] if len(sys.argv) > 1 else None
PROMPT = sys.argv[2] if len(sys.argv) > 2 else None
SIZE = sys.argv[3] if len(sys.argv) > 3 else "1024x1024"
QUALITY = sys.argv[4] if len(sys.argv) > 4 else "high"

if not IMG_PATH or not PROMPT:
    print("Usage: python3 scripts/img2img.py <image_path> <prompt> [size] [quality]")
    sys.exit(1)

if not os.path.exists(IMG_PATH):
    print(f"ERROR: Image file not found: {IMG_PATH}")
    sys.exit(1)

# Get API key from sqlite
conn = sqlite3.connect('/home/ubuntu/.openclaw/agents/main/agent/openclaw-agent.sqlite')
cur = conn.cursor()
cur.execute('SELECT store_json FROM auth_profile_store WHERE store_key = "primary"')
data = json.loads(cur.fetchone()[0])
API_KEY = data['profiles'].get('aethercode:default', {}).get('key', '')
conn.close()

if not API_KEY:
    print("ERROR: No API key found")
    sys.exit(1)

# Read and encode image
with open(IMG_PATH, "rb") as f:
    img_base64 = base64.b64encode(f.read()).decode('utf-8')

payload = json.dumps({
    "model": "gpt-image-2",
    "prompt": PROMPT,
    "size": SIZE,
    "quality": QUALITY,
    "image": img_base64
}, ensure_ascii=False).encode("utf-8")

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

print("🎨 Generating image with reference...")
req = urllib.request.Request(
    "https://api.aetheracode.com/v1/images/generations",
    data=payload,
    headers=headers,
    method="POST"
)

try:
    with urllib.request.urlopen(req, timeout=180) as response:
        result = json.loads(response.read().decode("utf-8"))
        if "data" in result and len(result["data"]) > 0:
            b64 = result["data"][0].get("b64_json", "")
            if b64:
                date_dir = f"/home/ubuntu/.openclaw/workspace/images/{time.strftime('%Y-%m-%d')}"
                os.makedirs(date_dir, exist_ok=True)
                out_path = f"{date_dir}/aetheracode_ref_{int(time.time())}.png"
                with open(out_path, "wb") as f:
                    f.write(base64.b64decode(b64))
                size = os.path.getsize(out_path)
                print(f"SUCCESS: {out_path}")
                print(f"Size: {size / 1024 / 1024:.1f}MB")
            else:
                print("No image data in response")
        else:
            print("Unexpected response:")
            print(json.dumps(result)[:500])
except urllib.error.HTTPError as e:
    try:
        err = json.loads(e.read().decode("utf-8"))
        print(f"HTTP {e.code}: {err}")
    except:
        print(f"HTTP Error: {e.code}")
