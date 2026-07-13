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

---

## 2026-07-02｜SSH Key 方向性問題

### 錯誤
從 Zeabur VM SSH 到 Oracle VM，嘗試用 `~/.ssh/id_ed25519_zo_new`（Oracle VM 上嘅 key），但呢個 key唔存在於 Zeabur VM。

### 根因
SSH key 係**有方向性**嘅——連接方需要自己嘅 private key，呢個 key 必須喺**被連接方**嘅 `authorized_keys` 入面。

### 正確做法
```bash
# 被連接方（Oracle）嘅 authorized_keys 必須有連接方（Zeabur）嘅 public key
# 從被連接方角度看：
# - Oracle 的 authorized_keys 裏有「Zeabur VM 的 public key」→ Zeabur 可連 Oracle
# 從連接方角度看：
# - Zeabur VM 執行 ssh，需要用自己嘅 private key（~/.ssh/zeabur_key）

# ✅ 從 Zeabur 連 Oracle
ssh -i ~/.ssh/zeabur_key opc@161.118.247.199

# ✅ 用 SSH config alias
ssh oracle-new  # (alias → 161.118.247.199, key: temp_opc_key 或 zeabur_key)
```

### 現有 SSH Keys 清理
| Key | 用途 |
|---|---|
| `zeabur_key` | 連 ZO VM + Oracle VM |
| `oracle_vm_new` | 舊 Oracle key，IP 已廢棄 |
| `id_ed25519_zo` | ZO VM 專用 |
| `temp_opc_key` | 新 Oracle IP（161.118.247.199）專用 |

### 防止再犯
> SSH 連接係「client 用自己嘅 key，去 server 嘅 authorized_keys 入面驗證」——搞清邊個係 client、邊個係 server。

---

## 2026-07-03｜Telegram Duplicate Token 導致 Bot 全線崩潰

### 錯誤
`channels.telegram.accounts.default` 同 `accounts.arslansky` 用咗**同一段 bot token**。

### 根因
OpenClaw Telegram plugin 初始化時 detect 到 duplicate token → `default` account fail → 成個 Telegram channel 變 `"not configured"` → 所有 incoming updates 唔被分發。

### 正確做法
1. `openclaw gateway call health` → 睇 `configured` 同 `lastError`
2. 對比所有 accounts 嘅 botToken：`cat openclaw.json | jq '.channels.telegram.accounts'`
3. 如果有 duplicate → 刪除多餘 account → restart gateway
4. 驗證：`curl -s "https://api.telegram.org/bot<TOKEN>/getMe"`

### 關鍵 lesson
- `connected: true` 唔代表 channel work → 要睇 `configured` 同 `lastError`
- `can_read_all_group_messages: true` 唔代表即刻收到 → 要有人 send message 先 trigger
- 兩個 OpenClaw instances 同一 token → 爭 updates

### 防止再犯
> 每次加新 bot account 前，先確認 token 唔喺其他 account 用緊。
> **省略 token 係俾人睇嘅，唔係俾機器用嘅。** 測試 API 前，先從 config 拎完整版本。

---

## 2026-07-13｜Image Generation Script API Drift

### 錯誤
多次生圖時繞過 `scripts/smart_image_gen.sh`，直接行 `image_generate` tool，導致用錯 API（Aetheracode 而非 Zhi）。

### 根因
1. image_generate tool 行 Aetheracode（default provider），唔係行 script
2. 每次生圖時貪快 → 用 tool 直接生成 → Aetheracode 爆 balance 先發現
3. script 早已 set 好 Zhi API，但從來唔係首選
4. MEMORY.md OVR-001 只寫「via script」，冇寫明係邊個 API provider，斷層後無法追溯

### 正確做法

**✅ 標準流程：**
```bash
# 每次生圖前確認 API
cat scripts/smart_image_gen.sh | grep -E "API_KEY|zhi-api"

# 生圖永遠行 script
bash scripts/smart_image_gen.sh "<prompt>" "<size>" "<quality>" "<model>"
```

**⚠️ 硬性規定（AGENTS.md）：**
- 永遠行 script，唔准用 image_generate tool 直接生成
- 生圖前必須確認 API endpoint 係 Zhi
