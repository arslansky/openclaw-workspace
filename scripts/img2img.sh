#!/bin/bash
# img2img wrapper for Aetheracode gpt-image-2 with reference image
# Usage: bash scripts/img2img.sh "<image_path>" "<prompt>" [size] [quality]

IMG_PATH="$1"
PROMPT="$2"
SIZE="${3:-1024x1024}"
QUALITY="${4:-high}"

if [ -z "$IMG_PATH" ] || [ -z "$PROMPT" ]; then
    echo "Usage: bash scripts/img2img.sh \"<image_path>\" \"<prompt>\" [size] [quality]" >&2
    exit 1
fi

if [ ! -f "$IMG_PATH" ]; then
    echo "ERROR: Image file not found: $IMG_PATH" >&2
    exit 1
fi

# Get API key from sqlite
API_KEY=$(python3 -c "
import sqlite3, json
conn = sqlite3.connect('/home/ubuntu/.openclaw/agents/main/agent/openclaw-agent.sqlite')
cur = conn.cursor()
cur.execute('SELECT store_json FROM auth_profile_store WHERE store_key = \"primary\"')
data = json.loads(cur.fetchone()[0])
print(data['profiles'].get('aethercode:default', {}).get('key', ''))
conn.close()
")

if [ -z "$API_KEY" ]; then
    echo "ERROR: No API key found" >&2
    exit 1
fi

# Convert image to base64
IMG_B64=$(base64 -w 0 "$IMG_PATH")

# Call Aetheracode API
echo "🎨 Generating image with reference..."
RESPONSE=$(curl -s --max-time 180 -X POST "https://api.aetheracode.com/v1/images/generations" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"model\": \"gpt-image-2\",
        \"prompt\": \"$PROMPT\",
        \"size\": \"$SIZE\",
        \"quality\": \"$QUALITY\",
        \"image\": \"$IMG_B64\"
    }" 2>&1)

if echo "$RESPONSE" | grep -q '"code":"INVALID_API_KEY"'; then
    echo "ERROR: Invalid API key" >&2
    exit 1
fi

if echo "$RESPONSE" | grep -q '"error"'; then
    echo "ERROR: API Error - $RESPONSE" >&2
    exit 1
fi

# Extract and save image
B64_DATA=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['b64_json'])" 2>/dev/null)

if [ -z "$B64_DATA" ]; then
    echo "ERROR: Failed to extract image data" >&2
    echo "Response: $RESPONSE" >&2
    exit 1
fi

# Save
DATE_DIR=$(date +%Y-%m-%d)
OUTPUT_DIR="/home/ubuntu/.openclaw/workspace/images/${DATE_DIR}"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +%s)
OUTPUT_FILE="${OUTPUT_DIR}/aetheracode_ref_${TIMESTAMP}.png"
echo "$B64_DATA" | python3 -c "import sys,base64; data=base64.b64decode(sys.stdin.read()); sys.stdout.buffer.write(data)" > "$OUTPUT_FILE"

if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
    echo "SUCCESS: $OUTPUT_FILE"
    echo "Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
else
    echo "ERROR: Failed to save image" >&2
    exit 1
fi
