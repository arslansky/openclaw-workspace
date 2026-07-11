# Tool Playbook｜OpenClaw 工具效果追蹤

> ACE 風格嘅工具 playbook——追蹤邊個 tool / script 喺邊類任務有效，逐步累積、演化。
> 
> Last updated: 2026-07-11

---

## 生圖工具

### smart_image_gen.sh（主力生圖）
| 任務類型 | 成功率 | 備註 |
|---|---|---|
| 人物肖像 | ~90% | Evie 角色設定穩定 |
| 風景 | ~85% | 颜色有時偏饱和 |
| 抽象概念 | ~70% | 依賴 prompt 精確度 |

**常見問題：**
- prompt 太長被截斷（max ~500 chars）
- 武器殘留問題 → 每次必須加 `no weapons`

**有效 pattern：**
- 先參考圖再 describe → 效果穩定
- `no weapons` tag 必須加喺最後

---

## 資訊獲取

### news_fetch.sh（晨早新聞）
| 指標 | 數值 |
|---|---|
| 成功率 | ~80% |
| 平均時間 | ~20-30s |
| 主要失敗原因 | 某些 news site 被 block |

**有效 pattern：**
- 大部分主流 news site 可用
- TechCrunch / The Information 穩定

### YouTube Transcript（字幕提取）
| 指標 | 數值 |
|---|---|
| 成功率 | ~75%（需要 SOCKS5 proxy）|
| 主要失敗原因 | IP 被 block、字幕唔存在 |

**有效 pattern：**
- 必須用 SOCKS5 proxy（s4.hk38.ltip.xyz:20105）
- Cantonese auto-caption quality ~70-80%

---

## PDF 處理

### gen_pdf.py
| 指標 | 數值 |
|---|---|
| 中文支援 | ✅（STSong-Light CID font） |
| Markdown 支援 | ✅ |
| 圖片支援 | ⚠️ 視乎 embedding |

**有效 pattern：**
- 輸入 `.txt` 或 `.md` 最穩定
- 輸出去 `/tmp/` 再 attach 到 Telegram

---

## 同步工具

### toolbox-daily-sync（04:00 cron）
| 指標 | 數值 |
|---|---|
| 成功率 | ~95%（通常重試後成功）|
| 主要失敗原因 | Model call timeout（凌晨 model 慢）|
| 重試機制 | ✅（内建）|

### workspace-daily-backup
| 指標 | 數值 |
|---|---|
| 成功率 | ~90% |
| 主要失敗原因 | Model call timeout |

---

## 反思準則

> 每次發現新 tool 效果 pattern → 追加呢個 playbook
> 每週六 inbox review → 檢查並更新 bullets
> 
> **核心原則：** 增量追加，唔整體重寫——避免 Context Collapse

---

*格式：ACE-style delta bullets*
