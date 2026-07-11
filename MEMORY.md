# MEMORY.md

## 圖片生成

- **所有生圖** → 用 `bash scripts/smart_image_gen.sh`
- **Model:** Aetheracode gpt-image-2（直接 call API，唔經 OpenClaw image provider）
- **Script 位置:** `~/.openclaw/workspace/scripts/smart_image_gen.sh`
- **Usage:** `bash scripts/smart_image_gen.sh "<prompt>" [size] [quality] [model]`
- **Example:** `bash scripts/smart_image_gen.sh "a cute robot" "1024x1024" "high" "gpt-image-2"`

### 常用 Prompt（2026-07-05）

**Evie 角色設定：**
- 亞洲女性，約16歲
- 精緻瓷肌，透紅
- 短黑棕色頭髮，微卷髮尾
- **心形面**（非鵝蛋面），五官精緻
- 柔和杏仁眼，自然雙眼皮
- 眼神：柔中堅定（soft but firm gaze）
- 淡妝，粉色腮紅

**Evie 眼型喜好（2026-07-10）：**
用呢個 reference 做 base：`~/.openclaw/media/inbound/71e567ae-4070-47db-a4de-0f7a9766d117.jpg`

眼型描述（偏好）：
1. **Soft Almond** — soft almond-shaped eyes, gentle innocent gaze, downward curved outer corners, innocent lively sparkle
2. **Large Round** — large round innocent eyes, big bright sparkling gaze, cute sweet expression
3. **Cat Eyes** — cat eyes with slightly upturned outer corners, mysterious smizing gentle gaze
4. **Monolid Soft** — monolid soft almond eyes, gentle innocent droopy gaze, sleepy vulnerable sweet
5. **Deep Set** — deep set soft eyes, gentle downward gaze, calm peaceful serene expression

**穿搭建議：**
- Cyberpunk 戰鬥服：white futuristic combat suit + glowing neon cyan accents
- 運動風：white dry athletic top + sports field background

---

## 🎨 Evie 最終五官選擇（2026-07-10）

**Reference:** `71e567ae-4070-47db-a4de-0f7a9766d117.jpg`

| 部位 | 選擇 | 描述 |
|---|---|---|
| 髮 | MEDIUM | black wet-look hair, slight outward curved tips |
| 眼 | A2 | Soft almond eyes, slight upward angle, warm sparkle |
| 眉 | B3 | Straight flat, slight lift at tail |
| 面 | C4 | Fox-shaped, narrow chin |
| 嘴 | D1 | Soft sweet gentle smile |
| 鼻 | E4 | Short soft cute, rounded tip |

**完整 Prompt：**
```
Asian woman portrait, luminous porcelain skin, MEDIUM black wet-look hair with slight outward curved tips, fox-shaped face with narrow chin, soft almond-shaped eyes with slight upward angle and warm sparkle, gentle innocent gaze, straight flat eyebrows with slight lift at tail, soft sweet gentle smile lips, short soft cute nose with rounded tip, light natural makeup with pink blush. White dry athletic top, sports field background, soft warm cinematic lighting, front facing, no text, no watermark
```

---

## 👁️ 眼型測試記錄（廢片參考）

| 代號 | 眼型 | 描述 |
|---|---|---|
| A1 | Soft Almond | downward curved corners, lively sparkle |
| A2 ✅ | Soft Almond | slight upward angle, warm sparkle | ← **選定** |
| A3 | Soft Almond | natural width, gentle glow |
| A4 | Soft Almond | relaxed eyelids, peaceful glow |
| A5 | Soft Almond | dreamy sparkle, dreamy expression |
| B | Large Round | big bright sparkling gaze |
| C | Cat Eyes | upturned outer corners |
| D | Monolid Soft | gentle droopy gaze |
| E | Deep Set | calm serene gaze |

**Evie cyberpunk 白戰鬥服（無武器）prompt（英文原版）：**
```
Asian woman portrait, delicate porcelain skin, short black-brown hair with subtle waves at ends, small sharp delicate heart-shaped face, gentle almond eyes with natural double eyelids, soft but firm gaze, light natural makeup with pink blush. Cyberpunk warrior in white futuristic combat suit with glowing neon cyan accents, tech-wear battle armor, sleek white LED trim, combat gloves, holographic HUD elements, battle-ready pose, dark moody lighting with cyan rim light, futuristic sci-fi aesthetic, highly detailed, cinematic, no weapons
```

**Evie cyberpunk 白戰鬥服（無武器）prompt（中文版）：**
```
寫真照片，亞洲女性，精緻瓷肌，短黑棕色頭髮，微卷髮尾，心形面，五官精緻，柔和杏仁眼，自然雙眼皮，眼神柔中堅定，淡妝，粉色腮紅。科幻戰鬥服，白色未來感機甲套裝，發光霓虹飾邊，技術戰鬥盔甲，光滑LED線條，戰鬥手套，全息HUD元素，戰鬥姿勢，暗色情緒照明，霓虹邊緣光暈，未來科幻美學，高品質，電影感
```

**人物參考圖：** `~/.openclaw/workspace/media/inbound/b3cf4f8a-7917-4516-9833-6ba74f58c220.jpg`

## Telegram Bot 設定（2026-07-05 更新）

### Bot ID 對照表

| Account | Bot ID | Username | Display Name |
|---|---|---|---|
| `arslansky` | `8688406477` | @arslanskybot | Kimi Boy |
| `janzaibot` | `8302835438` | @Janzaibot | Big VM |
| `know2learn` | `8401590390` | @Know2learn_bot | 知識庫熔爐 |
| `zo` | `8205470881` | @ZO_001_bot | **Last Guardian 2** |
| `ds` | `8523709022` | @DS_26bot | Deepseekbot |

### 用途
- `arslansky` — 主要私人對話
- `janzaibot` — Big VM bot（用途待確認）
- `know2learn` — **知識庫 bot**，inbox capture + 知識沉澱
- `zo` — **Last Guardian 2**（ZO Computer VM 配套 bot）
- `ds` — **Deepseekbot**（用途待確認）

### Group ID 對照

| Group ID | Name | 服務 Bot |
|---|---|---|
| `-1003897497805` | Kimi 綜合工作區（forum topic:1）| @arslanskybot |
| `-1003859753438` | GPT-Image-2 Creation Bot | @arslanskybot |
| `-5530265702` | English Learning | @arslanskybot |
| `-1003924885824` | 知庫群組（forum）| @arslanskybot（know2learn group ingress 已壞）|

## 知識庫 Vault（2026-07-05）

- **位置：** `~/obsidian/knowledge/`
- **呢個 bot（know2learn）所有對話內容** → 預設自動入 inbox `~/obsidian/knowledge/00-Inbox/`
- **流程：** inbox → 我哋一齊消化 → atomic notes → permanent notes
- **Workflow 規則：** `~/obsidian/knowledge/00-Inbox/WORKFLOW.md`
- **每週六 10 點（GMT+8）** → cron remind review inbox

### inbox 指令
任何時侯喺呢個 bot 話我知就得：
```
inbox: [任何嘢]
```
你唔使寫完整，一句都好，我幫你寫入 inbox。

- **Config位置：** `~/.openclaw/openclaw.json`
- 三個account完全分開，唔存在token衝突
- 所有group設定 `requireMention: false`（唔使@都會回）
- arslansky嘅 `richMessages: false`

### 常見問題
- gateway重啟後有時janzaibot/know2learn會甩線，試restart解決
- **know2learn group ingress 已壞**：Bot ID `8401590390` `has_topics_enabled: false`，Telegram 唔 delivery forum group messages。需 `/deletebot` + `/newbot` 重建。
- **Debug工具：**
  - `openclaw gateway call health` → 查看各account connected狀態
  - `curl http://127.0.0.1:18789/health` → gateway是否活着

## 🖼️ 生圖觸發規則（2026-07-07 追加）

**⚠️ 每次生圖必須行呢個流程，唔准跳過：**

1. **嚴格跟流程：生圖請求 → `bash scripts/smart_image_gen.sh`**
2. **唔准用 `image_generate` tool** —— 呢個係 miss trigger 根源，會默認用 minimax
3. **Prompt 尾加 tag**：`no weapons`（MEMO：之前有次出錯漏咗武器）
4. **Scripts 位置：** `~/.openclaw/workspace/scripts/smart_image_gen.sh`
5. **模型：** `gpt-image-2`（固定，唔准改，除非 script 本身 fail）
6. **Output：** `~/.openclaw/workspace/images/YYYY-MM-DD/`

**觸發關鍵詞（任何一個都觸發）：**
- 生圖 / generate image / create image / 画
- image prompt / 描述角色
- 再生成 / regenerate

**出事紀錄（2026-07-07）：** 第一次 request 我用咗 `image_generate` tool 導致用咗 minimax model，user 提醒先知用錯。根因係 native tool 搶佔咗 workflow。

## Image Model 問題（2026-07-05）

- **zhi-api/kimi-k2.6 已死**（502 Bad Gateway）
- Group `-1003859753438`（GPT-Image-2 Creation Bot）由 arslansky bot 服務，生圖功能已壞
- 需要盡快更換可用嘅 image model provider

## English Learning Group（2026-07-05）

- **Group Name:** English Learning
- **Group ID:** `-5530265702`
- **用途:** 英文學習、英文寫作為主
- **Bot:** arslansky（@arslanskybot）

## 三台 VM（2026-07-05 更新）

| VM | Host | User | Port | Auth | 狀態 |
|---|---|---|---|---|---|
| **Oracle VM** | `161.118.247.199` | `opc` | 22 | `~/.ssh/zeabur_key` | ✅ |
| **Zeabur VM** | `43.156.247.30` | `ubuntu` | 22 | Password / SSH key | ✅（呢部係我哋目前嘅 Gateway）|
| **ZO VM** | `ts8.zocomputer.io` (`150.136.143.138`) | `root` | 10661 | `~/.ssh/zeabur_key` | ✅ |

## ACE Feedback Loop（2026-07-11 追加）

**每個 script/tool 執行完必須寫 log：**
```bash
# 追加格式（JSONL）
echo '{"script": "...", "task": "...", "success": true, "duration_sec": N, "note": "..."}' >> memory/tool-log.jsonl
```
- **禁止空白**——起碼要有 task description
- **臨時日誌：** `memory/tool-log.jsonl`
- **每週六：** inbox review 時同步更新 `memory/tool-playbook.md`

---

## TRAP 雙層規劃（2026-07-11 追加）

**所有複雜任務** → 建立 `memory/tasks/active/<task-id>/`

```
memory/tasks/
├── _registry.md          # 任務總表（TRAP-style）
├── active/
│   └── <task-id>/
│       ├── _plan.md      # Abstract Plan（高層目標）
│       └── _subtasks.md  # Field-mapped subtasks
└── completed/            # 完成歸檔
```

**操作流程：**
1. 複雜任務進來 → 建立 task-id folder
2. 寫 `_plan.md`（高層 Abstract Plan + phase map）
3. 寫 `_subtasks.md`（每 phase checklist，field-mapped）
4. 完成 → 移動去 `completed/`，更新 `_registry.md`
5. **任何 blocker 出現** → 立即寫入 `phase_N_blocker`，及時上報

**失敗模式分類（每個失敗必須標記）：**
- `myopic` — 逐步最優但整體唔優
- `plan_drift` — 做到一半偏離原本目標
- `short_term_bias` — 細節靚但宏觀走咗
- `other` — 其他原因

---

## SICA 落地應用（2026-07-11 追加）

**每次任務失敗** → 建立呢個循環：
```
reasoning_agent（我）→ 分析邊個 tool/script 失敗
    ↓
coding_agent（我）→ edit scripts（加 fallback / log / retry）
    ↓
tool-log.jsonl → 記錄 failure pattern
    ↓
下次執行 → 驗證修復是否有效
```

**長期目標：** 逐步自動化，最終做到「系統自己識得優化自己」

---

### SSH 快速指令
```bash
# Oracle
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ~/.ssh/zeabur_key opc@161.118.247.199

# ZO
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p 10661 -i ~/.ssh/zeabur_key root@ts8.zocomputer.io
```

### 已知問題
- Oracle 舊 IP `129.80.234.56` 已廢棄，現時用 `161.118.247.199`

## Hermes Backup（Oracle VM）設定

### 位置
- **Oracle VM:** `opc@161.118.247.199`
- **Backup 目錄:** `/home/opc/hermes-backup/`
- **News Summary:** `/home/opc/hermes-backup/news-summary/`
  - `news_summary.py` + `news_summary.sh`

### 結構
```
hermes-backup/
├── archive/
├── config/
├── inventory.yml
├── news-summary/      ← News Summary 脚本 ✅
├── README.md
├── scripts/           ← 各類工具脚本
├── setup-guide/
└── skills/
```

### 做法
- News summary 脚本喺 Oracle VM 呢度
- 同步去 Zeabur 用 `sync-all-vms.sh`

## Toolbox（2026-07-09）

- **Repo:** https://github.com/arslansky/toolbox
- **結構:** hermes/ (29 scripts) + openclaw/ (11 scripts) + shared/ + sync.sh
- **同步方式:** 直接 clone，唔用 symlink
- **每日 cron:** 04:00 Asia/Shanghai 自動 sync
- **Backup:** scripts.bak.20260709/ 保留舊版

## 📊 AI 新聞顧問分析框架（2026-07-10）

### 觸發條件（日常 summary ≠ 顧問模式）
出现以下任意一个 → 自动升级为顾问模式：
- 創投金額 > $100M
- 知名研究者（一級 source）親口說
- 技術方向逆轉（之前業界共識被挑戰）
- 涉及你自己的實際決策（模型選型、架構、投資）

### 觸發指令
> 「顧問模式分析呢篇」

---

### 9步分析流程

**Step 1 — Source 溯源（消息源分級）**
| 等級 | 定義 |
|------|------|
| 一級 | 科學家/研究者親口說（Noam Brown、Fei-Fei Li） |
| 二級 | 深度報導（TechCrunch、The Information） |
| 三級 | 轉述/解讀（動區、Twitter thread） |
| 四級 | 公關稿包裝成新聞 |

**Step 2 — 利益方定位**
- 邊個講？幾時講？點解係呢個時間？
- 邊個受益？
- 任何「呢樣嘢會被取代」的說法，要問：取代緊誰？

**Step 3 — 技術約束 vs Marketing**
- 係底層演算法/算力/數據嘅突破，定係engineering堆砌？
- Demo表演 ≠ 成熟產品
- 學術界有冇保留意見？

**Step 4 — 方向 × 時間（長短拆開）**
| 層次 | 問題 |
|------|------|
| 方向啱唔啱？ | long-term trend |
| 幾時發生？ | 1年？5年？呢個先係真正uncertainty |

**Step 5 — 框架識別**
- Big Model 派 framework：Bitter Lesson — 計算係王，engineering係臨時橋樑
- Big Harness 派 framework：Production Reality — 真實部署有无数细节，模型不是银弹
- 兩個都係真，問題係喺唔同意義系統入面討論

**Step 6 — 不變量 vs 暫時優勢**
不變量（長期有意義）：
- 物理世界互動數據嘅稀缺性
- 推理能力嘅 scaling 規律
- 部署可靠性嘅必要成本

暫時優勢（容易被顛覆）：
- 任何靠 current model 能力上限嘅 workaround
- 任何靠「模型未內建」嘅 scaffolding

**Step 7 — 缺席的聲音**
- 邊個冇喺度講嘢？
- 創投/記者吹捧緊，但領域內 research scientist 點睇？

**Step 8 — 決策代價**
- 如果信咗，錯咗代價係幾多？
- 如果錯過咗，對嘅代價係幾多？

**Step 9 — 主動對立面搜索 + 預測筆記**
- 每次分析：主動搵最強反調——「邊個係最sharp的反對意見？」
- 有立場預測 → 寫入 `memory/ai-predictions.md` 入庫追蹤
- 之後翻睇，係咪應驗，定期更新命中率

---

### Output 格式分級

| 格式 | 用途 |
|------|------|
| 速讀版（3-5句） | 即時 TG 回覆 |
| 標準版（9步框架） | 一般深入分析 |
| 決策簡報版 | 涉及你實際取捨時 |
| 預測追蹤版 | 有立場預測後，入庫 |

---

### 框架 self-review（每季）
每季檢查一次：
1. 過去3個月預測命中率點評
2. 有無框架未覆蓋嘅分析盲點
3. AI 行業基本假設有無逆轉

---

### 更新記錄
- 2026-07-10：初始化框架

---

## 🔬 Harness Engineering 研究專題（2026-07-11）

**主文件：** `~/obsidian/knowledge/02-Permanent/harness-engineering.md`

### 目的
集中管理所有 Harness Engineering 相關資料，形成可疊加累積嘅研究庫。

### 目前進度
- ✅ Lilian Weng《Recursive Self-Improvement》博客影片總結（YouTube z_F0z7wF5XU）已消化
- ✅ 主研究 note 已創建：`02-Permanent/harness-engineering.md`

### 核心標籤
`#AI` `#Harness-Engineering` `#Agent` `#Self-Improvement` `#Research`

### 搜尋口徑（關鍵詞）
任何時候補充資料時，用以下關鍵詞搜索現有 vault：
```
harness / self-improv / recursive / agentic context
SICA / ACE / TRAP / context engineer
MCE / Meta-Harness / STOP / DGM / AlphaEvolve
workflow* agent / self-harness / self-taugh
```

### 與顧問框架嘅關係
在顧問分析框架 Step 5 中：
> Big Model 派：Bitter Lesson — 計算係王
> Big Harness 派：Production Reality — 真實部署細節

Harness Engineering 研究 = 逐步建立「Big Harness 派」嘅完整知識底座。

### 待整合（未來發現時更新）
- [ ] Lilian Weng 原文博客
- [ ] ACE / SICA 論文原文
- [ ] DGM vs STOP 對比
- [ ] MCE（Meta Context Engineering）
- [ ] ADAS / AFlow 工作流搜索

