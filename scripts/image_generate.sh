#!/bin/bash
# Aetheracode Image Generator Wrapper
# Usage: ./image_generate.sh "prompt" [size]

PROMPT="$1"
SIZE="${2:-1024x1536}"
API_KEY="${AETHERCODE_API_KEY:-sk-34d…38fd}"
OUTPUT_DIR="/tmp"

if [ -z "$PROMPT" ]; then
    echo "Usage: $0 'prompt' [size]" >&2
    exit 1
fi

# Call Aetheracode API
RESPONSE=$(curl -s -X POST "https://api.aetheracode.com/v1/images/generations" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"model\": \"gpt-image-2\",
        \"prompt\": \"$PROMPT\",
        \"size\": \"$SIZE\",
        \"quality\": \"high\"
    }" 2>&1)

# Check for errors
if echo "$RESPONSE" | grep -q '"code":"INVALID_API_KEY"'; then
    echo "ERROR: Invalid API key" >&2
    exit 1
fi

if echo "$RESPONSE" | grep -q '"error"'; then
    echo "ERROR: $RESPONSE" >&2
    exit 1
fi

# Extract base64 image
B64_DATA=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['b64_json'])" 2>/dev/null)

if [ -z "$B64_DATA" ]; then
    echo "ERROR: Failed to extract image data" >&2
    exit 1
fi

# Save image
OUTPUT_FILE="$OUTPUT_DIR/aetheracode_$(date +%s).png"
echo "$B64_DATA" | python3 -c "import sys,base64; data=base64.b64decode(sys.stdin.read()); sys.stdout.buffer.write(data)" > "$OUTPUT_FILE"

if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
    echo "SUCCESS: $OUTPUT_FILE"
    file "$OUTPUT_FILE"
else
    echo "ERROR: Failed to save image" >&2
    exit 1
fi
