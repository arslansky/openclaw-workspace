# MEMORY.md - 長期記憶

## 文件位置更新

**2026-06-25 重組後：**
- `core/` - SOUL.md, IDENTITY.md, USER.md, AGENTS.md, README.md
- `config/` - quick_reference.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, SETUP_GUIDE.md
- `para/projects/` - 進行中項目
- `para/areas/` - 長期維護區域
- `para/resources/memory/` - 每日記錄
- `para/resources/references/` - 參考資料
- `para/archives/` - 已完成項目
- `ops/scripts/` - 工具腳本
- `ops/skills/` - 技能定義
- `temp/weekly/` - 每週臨時記錄

---

## VM 連接資訊

### ZO Computer VM (modal)
- **Host:** `ts8.zocomputer.io:10661`
- **User:** `root`
- **Key:** `~/.ssh/id_ed25519` (注意：唔係 `id_ed25519_zo`)
- **SSH Config:** `Host modal` (已配置，直接用 `ssh modal`)
- **狀態:** ✅ 已連接
- **OS:** modal
- **備註:** 低負載 (load: 0.00)

### Zeabur Devbox
- **狀態:** ❌ 未連接 (需要正確 IP/hostname)
- **Key:** `~/.ssh/zeabur_devbox.pem`
- **備註:** 待測試

### Oracle Cloud VM
- **Host:** `140.245.111.2`
- **User:** `opc`
- **Key:** `~/.ssh/oracle_vm.pem`
- **狀態:** ✅ 已連接
- **OS:** Oracle Linux 9.7
- **Disk:** 30GB (90% full)
- **RAM:** 16GB

---

## Telegram 發送文件

**方法：** 用 Telegram Bot API (`sendDocument` / `sendPhoto`)
**Token 位置：** `config/quick_reference.md`
**指令格式：**
```bash
curl -s -X POST "https://api.telegram.org/botTOKEN/sendDocument" \
  -F "chat_id=CHAT_ID" \
  -F "document=@FILE_PATH" \
  -F "caption=DESCRIPTION"
```

**適用文件類型：**
- txt file
- pdf file
- 任何文件類型

**參考：** 明報社評自動推送（#2375）用相同方法

---

## 檔案放置決策樹（每次創建新檔前必執行）

### 條件判斷

| 問題 | YES → 放邊 | NO → 下一題 |
|------|-----------|------------|
| 係工具/scraper script？ | /root/scripts/ | ↓ |
| 係大檔 (>1MB)？ | /root/data/[category]/ | ↓ |
| 係個人學習/筆記？ | para/areas/english-learning/ | ↓ |
| 係一次性工作產出？ | workspace（事後標記 delete） | → default: workspace |

### 預設路徑

| 類型 | 路 |
|------|------|
| 工具 | /root/scripts/[name]/ |
| 爬蟲輸出 | /root/mingpao/ |
| 大檔 | /root/data/[category]/ |
| 個人學習 | para/areas/english-learning/[topic]/ |
| Agent 工作產出 | workspace |
| 明報社評 | /root/mingpao/editorials/ |
| **明報社評導讀 Skill** | `~/.agents/skills/mingpao-editorial-guide/` |

---

## 文件位置更新

**2026-06-25 重組後：**
- `core/` - SOUL.md, IDENTITY.md, USER.md, AGENTS.md, README.md
- `config/` - quick_reference.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, SETUP_GUIDE.md
- `para/projects/` - 進行中項目
- `para/areas/` - 長期維護區域
- `para/resources/memory/` - 每日記錄
- `para/resources/references/` - 參考資料
- `para/archives/` - 已完成項目
- `ops/scripts/` - 工具腳本
- `ops/skills/` - 技能定義
- `temp/weekly/` - 每週臨時記錄

---

## 用戶偏好

- 語言：廣東話傾偈，英文/技術術語
- 回覆風格：直接、簡潔、structural
- 常用工具：check [word] 查字典

---

## 文件位置更新

**2026-06-25 重組後：**
- `core/` - SOUL.md, IDENTITY.md, USER.md, AGENTS.md, README.md
- `config/` - quick_reference.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, SETUP_GUIDE.md
- `para/projects/` - 進行中項目
- `para/areas/` - 長期維護區域
- `para/resources/memory/` - 每日記錄
- `para/resources/references/` - 參考資料
- `para/archives/` - 已完成項目
- `ops/scripts/` - 工具腳本
- `ops/skills/` - 技能定義
- `temp/weekly/` - 每週臨時記錄

---

## 已建立 Skills

- **dictionary-lookup** — trigger: check [word]
  路徑：~/.agents/skills/dictionary-lookup/

---

## 文件位置更新

**2026-06-25 重組後：**
- `core/` - SOUL.md, IDENTITY.md, USER.md, AGENTS.md, README.md
- `config/` - quick_reference.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, SETUP_GUIDE.md
- `para/projects/` - 進行中項目
- `para/areas/` - 長期維護區域
- `para/resources/memory/` - 每日記錄
- `para/resources/references/` - 參考資料
- `para/archives/` - 已完成項目
- `ops/scripts/` - 工具腳本
- `ops/skills/` - 技能定義
- `temp/weekly/` - 每週臨時記錄

---

## Puppeteer 共用機制

### 安裝位置
```
/root/.openclaw/workspace/node_modules/puppeteer
```

### 引用方式
```javascript
// 所有 script 統一用呢個格式
const puppeteer = require('/root/.openclaw/workspace/node_modules/puppeteer');
```

### 後備機制（環境變數）
```bash
export OPENCLAW_WORKSPACE=/root/.openclaw/workspace
```
```javascript
const puppeteer = require(process.env.OPENCLAW_WORKSPACE + '/node_modules/puppeteer');
```

### 幾時要用
| 情況 | 用唔用 |
|------|--------|
| 普通 HTML | ❌ 用 curl/fetch |
| JavaScript 渲染 | ✅ 要用 |
| Cloudflare/反爬 | ✅ 要用 |
| 截圖/PDF | ✅ 要用 |

### 資源佔用
| 項目 | 大小 |
|------|------|
| puppeteer 套件 | 132KB |
| Chrome 瀏覽器 | 380MB |
| RAM 運行時 | 100-300MB |

---

## 文件位置更新

**2026-06-25 重組後：**
- `core/` - SOUL.md, IDENTITY.md, USER.md, AGENTS.md, README.md
- `config/` - quick_reference.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, SETUP_GUIDE.md
- `para/projects/` - 進行中項目
- `para/areas/` - 長期維護區域
- `para/resources/memory/` - 每日記錄
- `para/resources/references/` - 參考資料
- `para/archives/` - 已完成項目
- `ops/scripts/` - 工具腳本
- `ops/skills/` - 技能定義
- `temp/weekly/` - 每週臨時記錄

---

## 新聞 Workflow

### 工具位置
- `/root/scripts/news/fetcher.js`
- `/root/scripts/news/summary.js`

### 數據位置
- `/root/.openclaw/data/news/raw/`
- `/root/.openclaw/data/news/summary/`

### 用法
```bash
node /root/scripts/news/news_summary.js <URL>
```

---

## 文件位置更新

**2026-06-25 重組後：**
- `core/` - SOUL.md, IDENTITY.md, USER.md, AGENTS.md, README.md
- `config/` - quick_reference.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, SETUP_GUIDE.md
- `para/projects/` - 進行中項目
- `para/areas/` - 長期維護區域
- `para/resources/memory/` - 每日記錄
- `para/resources/references/` - 參考資料
- `para/archives/` - 已完成項目
- `ops/scripts/` - 工具腳本
- `ops/skills/` - 技能定義
- `temp/weekly/` - 每週臨時記錄

---

_📅 2026.06.24_