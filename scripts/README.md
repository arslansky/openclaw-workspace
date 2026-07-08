# Image Generation Scripts

## 生圖（智能膠）

**所有生圖** → 用 `smart_image_gen.sh`

```bash
bash scripts/smart_image_gen.sh "<prompt>" [size] [quality] [model]
```

**參數：**
- `prompt` — 圖片描述（必填）
- `size` — 尺寸，預設 `1024x1024`（可選：`1536x1024`, `1024x1536` 等）
- `quality` — 質量，預設 `high`（可選：`medium`, `low`）
- `model` — 模型，預設 `gpt-image-2`（可選其他 Aetheracode 模型）

**Example:**
```bash
# 生一張美女圖
bash scripts/smart_image_gen.sh "a beautiful woman, portrait, soft lighting" "1024x1024" "high"

# 16:9 風景
bash scripts/smart_image_gen.sh "mountain landscape, golden hour" "1536x1024" "high"
```

**流程：** prompt → Aetheracode API (gpt-image-2) → base64 decode → PNG 存到 `images/YYYY-MM-DD/`

**API Key：** 自動從本地 SQLite database 拎，唔使手動設定。

---

## 其他 Script

- `img2img.sh` / `img2img.py` — 圖生圖（以圖生圖）
- `image_generate.sh` — 備用生圖 script
- `organize_images.sh` — 整理 images 目錄
- `weekly-skills-backup.sh` — 每週 skills 備份
