# 快速參考 - 常用 Token 同指令

## Telegram Bot Tokens

| Bot | Token | Status |
|-----|-------|--------|
| **Kimi Boy** | `[BOT_TOKEN_REDACTED]` | ✅ |
| **Zeabur01Bot** | `[BOT_TOKEN_REDACTED]` | ✅ |
| **Know2learn Bot** | `[BOT_TOKEN_REDACTED]` | ✅ |
| **Hermes** | `[BOT_TOKEN_REDACTED]` | ✅ |
| **Deepseekbot** | `[BOT_TOKEN_REDACTED]` | ✅ |
| **Big VM** | `[BOT_TOKEN_REDACTED]` | ✅ |

### 發送文件指令
```bash
curl -s -X POST "https://api.telegram.org/botTOKEN/sendDocument" \
  -F "chat_id=160408068" \
  -F "document=@FILE_PATH"
```

### 發送圖片指令
```bash
curl -s -X POST "https://api.telegram.org/botTOKEN/sendPhoto" \
  -F "chat_id=160408068" \
  -F "photo=@IMAGE_PATH"
```

---

## Aetheracode API

### API Key (直接複製貼上)
```
sk-9a2e1fb4fcbc71cc6b9bf505b52e5ea48e8337025cf935652d3cbfd0050effcb
```

### 圖片生成指令 (直接複製貼上)
```bash
curl -s -X POST "https://api.aetheracode.com/v1/images/generations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [REDACTED]" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "PROMPT_HERE",
    "size": "1024x1536",
    "quality": "high"
  }'
```

---

## TTK API

### API Key (直接複製貼上)
```
sk-dJfy8GWR5czhLBHtvSmkrsWy0ZV6js5fT5e2WuAoJsQfRNAd
```

### 聊天指令 (直接複製貼上)
```bash
curl -s -X POST "https://api.ttk.homes/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [REDACTED]" \
  -d '{
    "model": "[按量计费]-gpt-5.5",
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

---

## GitHub

### Token (直接複製貼上)
```
ghp_[REDACTED]
```

### 創建 Repo 指令 (直接複製貼上)
```bash
curl -s -X POST -H "Authorization: token ghp_[REDACTED]" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{"name":"REPO_NAME","private":true}'
```

---

## MiniMax API

### API Key (直接複製貼上)
```
sk-cp-mNrtisBo685K4E_h9tViioU44JVLDP89yIhrVXnSqJUOH8pCoK0DdMV2qN0JhIpqhH9RU84B5wd6JyW4t6JnOJYaJGMfagw1ogF1gsSwrQoEVla8-ufgFVc
```

### Endpoint
- **OpenAI 兼容:** `https://api.minimax.io/v1`
- **Anthropic 格式:** `https://api.minimax.io/anthropic`

### 常用模型
- `MiniMax-M2.7` — 通用對話
- `MiniMax-M3` — 1M context，多模態

### 認證方式
- OpenAI 兼容: `Authorization: Bearer TOKEN`
- Anthropic 格式: `x-api-key: TOKEN`

### 聊天指令 (OpenAI 兼容)
```bash
curl -s -X POST "https://api.minimax.io/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [REDACTED]" \
  -d '{
    "model": "MiniMax-M2.7",
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

---

- **只複製貼上，唔好自己打字**
- **每次用前先打開呢個文件複製**
- **唔好相信記憶，記憶會省略**

---
*更新時間: 2026-06-19*
