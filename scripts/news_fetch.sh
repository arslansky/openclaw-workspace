#!/bin/bash
# news_fetch.sh - 拎新聞全文，專攻JS渲染頁面
# Usage: bash news_fetch.sh "<URL>"
# Output: 乾淨嘅文章正文

set -e

URL="$1"
if [ -z "$URL" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

# 用 curl 扮 browser bypass JS wall
HTML=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    -L --compressed \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: zh-HK,zh-TW,zh;q=0.9,en;q=0.8" \
    "$URL")

# 方法1: 從 Vue app 嵌入式 JSON 拎 content（881903用呢個）
CONTENT=$(echo "$HTML" | grep -oP '"content"\s*:\s*"[^"]*(?:<[^>]*>[^"]*)*"' | head -1)

if [ -n "$CONTENT" ]; then
    # 淨化HTML標籤
    echo "$CONTENT" | sed 's/<[^>]*>//g' | sed 's/&nbsp;/ /g' | sed 's/&amp;/\&/g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g' | sed 's/&#39;/'"'"'/g' | sed 's/&quot;/"/g' | tr -s ' ' | cat
    exit 0
fi

# 方法2: 從 article_contents array 拎
CONTENT2=$(echo "$HTML" | grep -oP '"article_contents"\s*:\s*\[.*?\]' | head -1)
if [ -n "$CONTENT2" ]; then
    echo "$CONTENT2" | sed 's/<[^>]*>//g' | tr -d '\\' | cat
    exit 0
fi

# 方法3: 直接試 textise dot iitty
TITLE=$(echo "$HTML" | grep -oP '(?<=<title>)[^<]+' | head -1)
echo "=== $TITLE ==="
echo "(未能自動提取正文，請手動複製）"
exit 1
