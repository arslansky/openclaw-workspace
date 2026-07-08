# Setup Guide - 新環境/重灌後必做

## 設計原則 (2026-06-18 確立)

### Single Source of Truth
- **唯一權威來源：** `config/quick_reference.md`
- **所有 API token、LLM model、endpoint 只喺呢度更新**
- **其他文件只引用，唔複製**

### 每次 Session 必讀
1. 打開 `config/quick_reference.md`
2. 複製所需 token/指令
3. 唔好自己打字，唔好靠記憶

---

## 新環境 Setup Checklist

### Step 1: 確認文件結構
```
workspace/
├── config/
│   ├── quick_reference.md  <-- 權威來源
│   ├── SETUP_GUIDE.md      <-- 呢個文件
│   ├── MEMORY.md
│   ├── TOOLS.md
│   └── reload_tokens.sh    <-- 重載 token 腳本
```

### Step 2: 設定環境變數（自動載入）
```bash
# 加入 .bashrc
echo 'source /root/.openclaw/workspace/config/reload_tokens.sh' >> ~/.bashrc

# 立即生效
source ~/.bashrc
```

### Step 3: 測試 Token 有效性
```bash
# Telegram Bot
curl -s "https://api.telegram.org/bot$(grep -o '86[0-9]*:[A-Za-z0-9_-]*' config/quick_reference.md | head -1)/getMe"

# Aetheracode API
curl -s -H "Authorization: Bearer $(grep -o 'sk-[A-Za-z0-9]*' config/quick_reference.md | head -1)" \
  https://api.aetheracode.com/v1/models
```

### Step 3: 驗證規則
- [ ] quick_reference.md 存在
- [ ] token 係完整版（冇 `…` 省略符號）
- [ ] 其他文件冇重複 token
- [ ] 可以成功發送 Telegram 訊息

---

## 長期維護機制

### 每月檢查 (Heartbeat)
```
檢查項目：
1. quick_reference.md 係咪最新？
2. 有冇新 API 要加入？
3. 有冇過期 token 要更新？
4. 其他文件有冇意外複製 token？
```

### 更新流程
```
發現新 API / Token 變動
    ↓
只更新 config/quick_reference.md
    ↓
測試新 token 有效
    ↓
刪除其他文件嘅舊版本
    ↓
完成
```

---

## 常見問題

### Q: 點解唔直接記喺 MEMORY.md？
A: MEMORY.md 會被讀取但可能遺漏，quick_reference.md 係專門設計俾快速複製。

### Q: 重灌後點確保唔會用錯 token？
A: 跟 Setup Checklist，先測試再使用。

### Q: 用耐咗會唔會變亂？
A: 每月 Heartbeat 檢查，發現問題即刻修正。

---

*建立時間: 2026-06-19*
*版本: v1.1*
