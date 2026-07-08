#!/bin/bash
# reload_tokens.sh - 當 quick_reference.md 更新時重新載入 token

if [ -f /root/.openclaw/workspace/config/quick_reference.md ]; then
    export TG_TOKEN=$(grep -o '86[0-9]*:[A-Za-z0-9_-]*' /root/.openclaw/workspace/config/quick_reference.md | head -1)
    export AETHER_TOKEN=$(grep -o 'sk-[A-Za-z0-9]*' /root/.openclaw/workspace/config/quick_reference.md | head -1)
    export TTK_TOKEN=$(grep -o 'sk-dJf[A-Za-z0-9]*' /root/.openclaw/workspace/config/quick_reference.md | head -1)
    echo "✅ Token 已重新載入"
else
    echo "❌ quick_reference.md 唔存在"
fi
