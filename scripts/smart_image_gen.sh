#!/bin/bash
# Smart Image Generator Wrapper for OpenClaw
# Auto-detects "生圖" / "image 2" / "生成圖片" commands
# Saves to workspace with metadata + tags
# Retry logic: up to 4 retries on timeout/failure

PROMPT="$1"
SIZE="${2:-1024x1024}"
QUALITY="${3:-high}"
MODEL="${4:-gpt-image-2}"
MAX_RETRIES=4
RETRY_COUNT=0

# Get key from sqlite
API_KEY=$(python3 -c "
import sqlite3, json
conn = sqlite3.connect('/home/ubuntu/.openclaw/agents/main/agent/openclaw-agent.sqlite')
cur = conn.cursor()
cur.execute('SELECT store_json FROM auth_profile_store WHERE store_key = \"primary\"')
data = json.loads(cur.fetchone()[0])
print(data['profiles'].get('aethercode:default', {}).get('key', ''))
conn.close()
")

# Workspace storage
DATE_DIR=$(date +%Y-%m-%d)
OUTPUT_DIR="/home/ubuntu/.openclaw/workspace/images/${DATE_DIR}"
mkdir -p "$OUTPUT_DIR"

if [ -z "$PROMPT" ]; then
    echo "ERROR: No prompt provided" >&2
    exit 1
fi

generate_image() {
    echo "🎨 Generating image with Aetheracode $MODEL..."
    echo "Prompt: $PROMPT"

    RESPONSE=$(curl -s --max-time 180 -X POST "https://api.aetheracode.com/v1/images/generations" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"prompt\": \"$PROMPT\",
            \"size\": \"$SIZE\",
            \"quality\": \"$QUALITY\"
        }" 2>&1)
    CURL_EXIT=$?

    # Check curl itself failed
    if [ $CURL_EXIT -ne 0 ]; then
        echo "CURL_ERROR: curl exited with code $CURL_EXIT (network/timeout issue)" >&2
        return 1
    fi

    # Check for API-level errors
    if echo "$RESPONSE" | grep -q '"code":"INVALID_API_KEY"'; then
        echo "API_ERROR: Invalid API key - check aethercode credentials" >&2
        exit 1
    fi

    if echo "$RESPONSE" | grep -q '"error"'; then
        ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error',{}).get('message',d.get('error','')))" 2>/dev/null)
        echo "API_ERROR: $ERROR_MSG" >&2
        exit 1
    fi

    # Check for empty response
    if [ -z "$RESPONSE" ] || [ "$RESPONSE" = "null" ]; then
        echo "API_ERROR: Empty response from API (possible timeout/server issue)" >&2
        return 1
    fi

    # Extract and save image
    B64_DATA=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['b64_json'])" 2>/dev/null)

    if [ -z "$B64_DATA" ]; then
        echo "PARSE_ERROR: Failed to extract b64_json from response" >&2
        echo "Response preview: $(echo "$RESPONSE" | head -c 200)" >&2
        return 1
    fi

    # Generate filename with timestamp
    TIMESTAMP=$(date +%s)
    OUTPUT_FILE="${OUTPUT_DIR}/aetheracode_${TIMESTAMP}.png"
    echo "$B64_DATA" | python3 -c "import sys,base64; data=base64.b64decode(sys.stdin.read()); sys.stdout.buffer.write(data)" > "$OUTPUT_FILE"

    if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
        echo "SUCCESS: $OUTPUT_FILE"
        echo "Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
        return 0
    else
        echo "FILE_ERROR: Failed to save image to disk" >&2
        return 1
    fi
}

# Main retry loop
while [ $RETRY_COUNT -le $MAX_RETRIES ]; do
    if generate_image; then
        exit 0
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))

    if [ $RETRY_COUNT -le $MAX_RETRIES ]; then
        echo "🔄 Retry $RETRY_COUNT/$MAX_RETRIES in 3 seconds..." >&2
        sleep 3
    fi
done

# All retries exhausted
echo "" >&2
echo "============================================" >&2
echo "❌ FATAL: All $MAX_RETRIES retries failed." >&2
echo "" >&2
echo "Likely causes:" >&2
echo "  1. API server overloaded (check status.aetheracode.com)" >&2
echo "  2. Prompt too complex (try shortening)" >&2
echo "  3. Network connectivity issue" >&2
echo "  4. API key quota exhausted" >&2
echo "  5. Server-side timeout (180s not enough)" >&2
echo "" >&2
echo "Action needed: Check API status or simplify prompt" >&2
echo "============================================" >&2
exit 1
