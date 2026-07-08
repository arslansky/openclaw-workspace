#!/bin/bash
IMG_PATH="$1"
CAPTION="$2"
TOKEN=$(jq -r '.channels.telegram.accounts.arslansky.botToken' /home/ubuntu/.openclaw/openclaw.json)
curl -s "https://api.telegram.org/bot$TOKEN/sendPhoto" \
  -F "chat_id=-1003859753438" \
  -F "photo=@$IMG_PATH" \
  -F "caption=$CAPTION" | jq '.ok'
