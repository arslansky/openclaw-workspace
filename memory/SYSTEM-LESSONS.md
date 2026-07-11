# System Lessons｜系統教訓

> 所有系統性錯誤、根因分析、防止再犯方案，寫喺呢度。

---

## 2026-07-11｜Telegram Bot Token 驗證失敗

### 錯誤
用 `curl` 測試 Telegram bot token 時，用咗**錯誤 token 格式**，導致 401 Unauthorized 誤判。

### 根因
1. Telegram API 測試時，token 格式必須完整：`bot<TOKEN>` 不能有省略號、空格
2. 從 Telegram message 複製 token 時，如果 message 係**省略格式**（`830283…epj8`），複製嘅係省略版本，唔係完整 token
3. 我冇先從 `openclaw.json` 拎完整 token，直接用 message 入面嘅省略 token 測試

### 正確做法

**❌ 錯誤示範：**
```bash
# 從 message 複製，省略號會令 token 無效
curl "https://api.telegram.org/bot820547…xmgE/getMe"
# Result: 401 Unauthorized（但 token 實際係有效）
```

**✅ 正確示範：**
```bash
# 方法1：直接用 openclaw.json 入面嘅完整 token
TOKEN=$(cat ~/.openclaw/openclaw.json | jq -r '.channels.telegram.accounts.zo.botToken')
curl -s "https://api.telegram.org/bot${TOKEN}/getMe"

# 方法2：如果 message 有完整 token，直接複製完整版本
curl -s "https://api.telegram.org/bot8205470881:AAG9eXIKbqkpyC.../getMe"
```

### 防止再犯
1. **唔好直接用 message 入面省略嘅 token**——省略格式係俾人睇嘅，唔係用嚟 API 呼叫
2. **永遠從 openclaw.json 拎完整 token**再做 API 測試
3. 呢個錯誤喺 HEARTBEAT.md / TOOLS.md 無法防止——係操作習慣問題

### 教訓
> **省略 token 係俾人睇嘅，唔係俾機器用嘅。** 測試 API 前，先從 config 拎完整版本。
