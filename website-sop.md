# Website SOP｜整網站思考手冊

> **目的：** 整網站時確保考慮周全，唔漏嘢，知道幾時用咩方法。
> **用法：** 開始新網站 project 前當 checklist 睇。
> **前置依賴：** 請先睇 `sop-master.md` Phase 1 確認問題，再睇呢份網站專用 SOP。

---

## 📋 導航目錄

```
Phase W1｜確認網站類型
Phase W2｜域名 + DNS
Phase W3｜前端考慮
Phase W4｜後端考慮
Phase W5｜存儲 + 媒體
Phase W6｜托管 + 部署
Phase W7｜安全
Phase W8｜SEO
Phase W9｜性能
Phase W10｜監控 + Analytics
Phase W11｜維護 + 更新
Phase W12｜Accessibility（無障礙）
Phase W13｜Social Sharing + Structured Data
Phase W14｜i18n（多語言）
Phase W15｜PWA（如適用）
Phase W16｜Legal（隱私政策 + 條款）
```

---

## Phase W1｜確認網站類型

> **先問：呢個係咩類型嘅網站？**

### 網站類型決策樹

```
靜態網站（無需登入）
├── 個人 Blog / Portfolio
│   └── 推薦：Static Site Generator（SSG）
│       - Astro（極速、静態優先）
│       - Hugo（最快 build）
│       - Eleventy（簡單、靈活）
│       → 托管：Cloudflare Pages / Vercel / GitHub Pages（免費）
│
├── 公司官網（無需登入）
│   └── 推薦：Astro / Next.js（static export）
│       → 托管：Vercel / Cloudflare Pages
│
└── Landing Page / 推廣頁
    └── 推薦：Astro + component library
        → 托管：Vercel（Speed test 強）

動態網站（需要登入 / 個人化）
├── Web App（SaaS / 工具）
│   └── 推薦：Next.js / Remix / Nuxt.js
│       → 需要 backend：Supabase / Firebase / 自建
│       → 托管：Vercel / Railway / Render
│
├── 內容網站（CMS 驱动）
│   └── 推薦：Next.js + CMS（Contentful / Sanity / Strapi）
│       → 托管：Vercel + CMS hosted separately
│
└── 電子商務
    └── 推薦：Shopify（唔想自己整）/ Medusa.js（想自己整）
        → 支付：Stripe / PayPal
```

### 必答問題

- [ ] **係靜態定動態？** 有冇 user login / 個人化内容？
- [ ] **主要用途？** Blog、官網、Web App、電商、内容網站？
- [ ] **目標用戶？** 桌面 / 移動 / 兩者都要？
- [ ] **預算？** 免費 / 低成本 / 可以花錢？
- [ ] **團隊大細？** 一个人 / 小團隊 / 大團隊？

---

## Phase W2｜域名 + DNS

### 域名選擇原則

```
✅ 好域名：
  - 短（< 15 chars）
  - 易讀、易記、易拼
  - 包含關鍵詞（如果係 SEO 導向）
  - .com / .io / .co 優先

❌ 避免：
  - 數字 + 字母混合（容易拼錯）
  - 雙關語 / pun（外國人唔明）
  - 太長
  - 奇怪後綴（.xyz / .info）
```

### DNS 托管推薦

| 需求 | 推薦 | 原因 |
|------|------|------|
| 一般網站 | Cloudflare（免費） | DNS + CDN + SSL + 安全性 |
| 快速生效 | Route 53（AWS）| 全球低延遲 |
| 免費 | Cloudflare | |

### DNS 記錄類型

| 記錄 | 用途 |
|------|------|
| **A** | 域名 → IPv4（例如 `93.184.216.34`）|
| **AAAA** | 域名 → IPv6 |
| **CNAME** | 子域名 → 另一個域名（例如 `www → @`）|
| **MX** | 郵件服務器（如果要自己 hosting email）|
| **TXT** | SPF / DKIM / DMARC（email security）|
| **ALIAS** | Apex domain → 另一個域名（Cloudflare 專用）|

**⚠️ 常見錯誤：** Apex domain（無 www）唔可以直接 CNAME，要：
- Cloudflare：Proxy + ALIAS record
- 或者用 redirect：apex → `www.example.com`

---

## Phase W3｜前端考慮

### 框架選擇決策矩陣

| 需求 | 推薦 | 理由 |
|------|------|------|
| 靜態為主、快速 | **Astro** | HTML-first、JS 只喺必要時用、極速 |
| React 生態 | **Next.js** | 最成熟、SSR/SSG/ISR 都支持 |
| Vue 生態 | **Nuxt.js** | Vue 3、簡潔 |
| 簡單、快速上手 | **Vite + Vanilla JS** | 輕量、無框架約束 |
| 移動優先、PWA | **React Native / Flutter** | 如果係移動 App |

### 組件庫選擇

| 需求 | 推薦 |
|------|------|
| 快速、美觀 | **Shadcn/UI**（Radix + Tailwind）|
| UI 元件齊全 | **MUI / Ant Design / Chakra UI** |
| 輕量 | **Headless UI / Kobalte** |
| 唔想自己整 | **Flowbite / DaisyUI**（Tailwind 組件）|

### CSS 策略

| 方案 | 適用場景 |
|------|----------|
| **Tailwind CSS** | Utility-first，最快開發速度 |
| **CSS Modules** | 團隊有 CSS 專家，想要完全控制 |
| **Styled Components / Emotion** | CSS-in-JS（有 runtime 開銷）|
| **UnoCSS** | Atomic CSS、極速 |

### 圖片策略

```
圖片優化流程：
  原始圖片
    ↓
  格式：WebP / AVIF（細 30-50%）
    ↓
  尺寸：responsive images（srcset）
    ↓
  加載：lazy load + blur placeholder
    ↓
  CDN 分發

工具：
  - Image optimization：Sharp / Cloudinary / imgix
  - CDN：Cloudflare / Vercel / CloudFront
```

---

## Phase W4｜後端考慮

### 後端選擇決策樹

```
需要 backend？
├── NO（靜態網站）
│   └── ✅ 搞掂，前端搞掂
│
├── YES
│   ├── 需要 database？
│   │   ├── NO → Serverless Functions 即可
│   │   │       （Vercel Functions / Netlify Functions / Cloudflare Workers）
│   │   │
│   │   └── YES
│   │       ├── 小型 / 快速原型
│   │       │   └── Supabase（PostgreSQL + Auth + Storage，免費 tier 够用）
│   │       │   Firebase（Firestore + Auth，Google 生態）
│   │       │   PlanetScale（MySQL，serverless）
│   │       │
│   │       ├── 中型 / 需要靈活
│   │       │   └── PostgreSQL + 自建 API
│   │       │       （FastAPI / Express / Hono）
│   │       │
│   │       └── 大型 / 高並發
│   │           └── 需要搵架構師
│   │
│   └── 需要 real-time？
│       ├── NO → REST API 即可
│       └── YES → WebSocket / Server-Sent Events
│           （Socket.io / Pusher / Ably）
```

### API 設計原則（參考 `sop-master.md` Phase 2 §8）

- REST 係默認選擇
- GraphQL 只喺 client 需要精確數據時先考慮
- 永遠 versioning（`/v1/` / `/v2/`）
- 永遠 HTTPS
- 永遠有 rate limiting

### Database 選擇

| 需求 | 推薦 |
|------|------|
| 關係型、SQL | PostgreSQL（Supabase / Neon / Railway）|
| 簡單、serverless | SQLite（Cloudflare D1 / Turso）|
| 文件導向 | MongoDB / Firebase Firestore |
| Cache / Session | Redis（Upstash / Redis Cloud）|

---

## Phase W5｜存儲 + 媒體

### 媒體存储原則

```
用戶上傳的圖片/文件：
  → Object Store（S3 / Cloudflare R2 / Uploadthing）

静态資源（CSS / JS / 圖）：
  → CDN（自動緩存）

唔好：
  ❌ Database 存二進制文件
  ❌ Server filesystem 存上傳文件（唔 scale）
```

### 推薦方案

| 需求 | 推薦 | 免費 tier |
|------|------|-----------|
| 圖片/文件上傳 | **Cloudflare R2**（S3-compatible，egress free）| 10GB storage |
| 圖片優化 | **Cloudflare Images** / **imgix** | |
| 視頻托管 | **Cloudflare Stream** / **Mux** | |
| Font 托管 | **Fontsource**（self-host fonts）| |

---

## Phase W6｜托管 + 部署

### 托管平台決策矩陣

| 網站類型 | 推薦托管 | 免費 tier |
|----------|----------|-----------|
| 靜態網站 | **Vercel** / **Cloudflare Pages** / **Netlify** | 全部有免費 |
| Next.js | **Vercel**（最佳 Next.js 支援）| 100GB bandwidth |
| React/Vue | **Netlify** / **Vercel** | |
| Node.js backend | **Railway** / **Render** / **Fly.io** | $5/月 起 |
| Full-stack | **Coolify**（self-hosted）| 免費（自己 server）|

### 部署流程

```
1. Git 連接
   GitHub / GitLab / Bitbucket
       ↓
2. 自動部署
   push → 觸發 build → 自動 deploy
       ↓
3. Preview Deployments
   每個 PR 自動生成 preview URL
       ↓
4. 生產環境
   main branch merge → 自動 production deploy
```

### CI/CD 必備

```
✅ 每次 Push：
  - Lint（ESLint / Prettier）
  - Type check（TypeScript）
  - Unit tests（Jest / Vitest）
  - Build test（確認 build 唔爆）

✅ 每次 PR：
  - Preview deployment
  - E2E tests（Playwright / Cypress）
  - Lighthouse CI（性能 baseline）

✅ 生產部署前：
  - Security scan（npm audit / Snyk）
  - Bundle size check
```

---

## Phase W7｜安全

### 安全 Checklist

#### 所有網站必做

```
[ ] SSL / HTTPS（Let's Encrypt 免費，托管平台自動）
[ ] CSP（Content Security Policy）header
[ ] HTTPS only cookies（Secure + HttpOnly + SameSite）
[ ] Input sanitization（XSS 防禦）
[ ] Password hashing（bcrypt / argon2，如果自己 hosting auth）
[ ] Rate limiting（防止暴力破解 / DDoS）
[ ] Security headers（CSP / X-Frame-Options / X-Content-Type-Options）
```

#### 表單 / User Input

```
[ ] Client-side validation（UX）
[ ] Server-side validation（安全，唔信 client）
[ ] CSRF token（如果係 stateful）
[ ] CAPTCHA（如果係公開表單，防止 spam）
[ ] File upload validation（type / size / malware scan）
```

#### 如果係電子商務 / 處理支付

```
[ ] PCI DSS 合規（如果自己處理 card data）
[ ] 使用 Stripe / PayPal（唔好自己存 card data）
[ ] 2FA（管理員帳戶）
[ ] 審計日誌（邊個幾時改咗咩）
```

### 依賴安全

```
[ ] npm audit（自動運行）
[ ] Dependabot / Renovate（自動更新依賴）
[ ] Snyk（更强嘅 security scanning）
[ ] 移除未使用嘅依賴
```

### Secrets 管理

```
[ ] API keys / tokens 唔好 hardcode（用環境變量）
[ ] 生產 secrets 用專用工具：
    - Cloudflare Workers → Workers Secrets
    - Vercel → Environment Variables（加密）
    - Railway → Runtime Variables
    - 自建 → HashiCorp Vault / AWS Secrets Manager
[ ] .env.example 檔（列出所有變量名，唔包括實際值）
[ ] 定期 rotate secrets（例如每 90 天）
[ ] 確認 secrets 唔會 log 出來 / 進 version control
```

---

## Phase W8｜SEO

### SEO Checklist（網站做好之後必做）

#### Technical SEO

```
[ ] 每個頁面有 unique <title>
[ ] 每個頁面有 unique <meta description>
[ ] 使用語義化 HTML（<main> / <article> / <nav> / <header> / <footer>）
[ ] Heading hierarchy 正確（<h1> 一個 / <h2>-<h6> 層次清晰）
[ ] XML Sitemap（`/sitemap.xml`）
[ ] Robots.txt（`/robots.txt`）
[ ] Canonical URL（防止 duplicate content）
[ ] 404 Page（優化 404 體驗）
```

#### Performance（影響 SEO）

```
[ ] Core Web Vitals 達標
    - LCP（ Largest Contentful Paint）< 2.5s
    - FID（First Input Delay）< 100ms
    - CLS（ Cumulative Layout Shift）< 0.1
[ ] Mobile-friendly（Google Mobile-First Indexing）
[ ] HTTPS（Google 強制要求）
```

#### Content SEO

```
[ ] 關鍵詞研究（Google Keyword Planner / Ahrefs / Semrush）
[ ] 頁面標題包含關鍵詞
[ ] URL 包含關鍵詞（`/blog/how-to-build-website` 而唔係 `/blog/123`）
[ ] 內部連結（相關文章互相連結）
[ ] 外部連結（連結到高質量 reference）
[ ] 圖片 alt text（包含關鍵詞但自然）
```

#### Indexing

```
[ ] Google Search Console 提交 sitemap
[ ] 確認 robots.txt 允許爬蟲
[ ] 確認冇 `noindex` 意外阻止頁面
```

---

## Phase W9｜性能

### 性能目標

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP | < 2.5s | 2.5s - 4s | > 4s |
| FID | < 100ms | 100ms - 300ms | > 300ms |
| CLS | < 0.1 | 0.1 - 0.25 | > 0.25 |
| TTFB | < 200ms | 200ms - 600ms | > 600ms |
| Bundle Size | < 200KB | 200KB - 500KB | > 500KB |

### 性能優化策略

#### 1. 減小 Bundle Size

```
[ ] Tree shaking（移除未使用代碼）
[ ] Code splitting（每個 page 獨立 chunk）
[ ] Lazy loading（`next/dynamic` / `React.lazy`）
[ ] 減少依賴（移除大庫）
[ ] 使用 lighter alternative（例如 moment → dayjs）
```

#### 2. 圖片優化

```
[ ] WebP / AVIF 格式
[ ] Responsive images（srcset）
[ ] Lazy loading（native `loading="lazy"`）
[ ] Blur placeholder（next/image）
[ ] 避免 LCP 元素延遲加載（above-the-fold 唔好 lazy load）
```

#### 3. Caching

```
[ ] CDN 緩存静态資源
[ ] Cache-Control headers
[ ] Service Worker（PWA，离线緩存）
[ ] API response caching（stale-while-revalidate）
```

#### 4. Server Performance

```
[ ] CDN（静态資源 + API routing）
[ ] Edge computing（Cloudflare Workers / Vercel Edge）
[ ] Database indexing（常用查詢有 index）
[ ] Query optimization（避免 N+1）
```

### 測試工具

| 工具 | 用途 |
|------|------|
| **Lighthouse** | 性能審計、SEO、Accessibility |
| **WebPageTest** | 深入分析每個請求 |
| **GTmetrix** | 速度測試 + 建議 |
| **Bundlephobia** | npm package 大小分析 |

---

## Phase W10｜監控 + Analytics

### 必須設置

```
[ ] Uptime Monitoring（網站係咪活著）
    → UptimeRobot（免費）/ Better Uptime

[ ] Error Tracking（JS 錯誤）
    → Sentry（免費 tier 有）

[ ] Analytics（用户行為）
    → Plausible（GDPR 友好，免費）
    → Google Analytics 4（功能强，但 privacy問題）
    → Umami（self-hosted，免費）
```

### Optional（根據需要）

```
[ ] Real User Monitoring（RUM）
    → Cloudflare Analytics
    → Sentry Browser Monitoring

[ ] Performance Monitoring
    → Web Vitals monitoring（Sentry / SpeedCurve）

[ ] Server Monitoring（如果自己 backend）
    → Grafana + Prometheus
    → Datadog
```

### 日誌

```
[ ] 錯誤日誌（server-side）
[ ] 訪問日誌（CDN 提供）
[ ] Audit logs（管理員操作）
[ ] 搜索日誌（如果係搜尋引擎）
```

---

## Phase W11｜維護 + 更新

### 維護 Checklist

```
日常
[ ] 監控 uptime（確認網站活著）
[ ] 檢查 error reports（Sentry）
[ ] 查看 analytics（用户係咪喺度？）

每週
[ ] 安全更新（依賴更新）
[ ] Content updates（如果係內容網站）
[ ] Backup 測試（確認可以恢復）

每月
[ ] Performance review（Lighthouse）
[ ] SEO review（Search Console）
[ ] Security audit（dependencies）

每季度
[ ] Full security review
[ ] 備份策略 review
[ ] 架構 review（係咪需要改）
```

### 備份策略

```
静态網站：
  → Git 就是 backup（code + content if in repo）
  → CDN edge nodes 就有 multiple copies

動態網站（database）：
  → Database：每日自動 backup（Supabase / PlanetScale 有內置）
  → Media files：Object Store 有 versioning
  → 配置：Infrastructure as Code（Terraform / Pulumi）

測試恢復：
  → 每季度測試一次 backup 可以正常恢復
```

---

## Phase W12｜Accessibility（無障礙）

> ⚠️ **Accessibility 唔係可選——法律要求（ADA/EAA）+ 擴大用戶群。**

### WCAG 2.2 AA 核心清單（2026 標準）

#### Perceivable（可感知）

```
[ ] 所有圖片有 alt text（裝飾性圖片用空 alt）
[ ] 影片有字幕（captions）
[ ] 音頻有 transcript
[ ] 顏色對比度 ≥ 4.5:1（正常文字）/ ≥ 3:1（大文字）
[ ] 文字可以縮放至 200% 而唔會問題
[ ] 唔好靠顏色傳達信息（要有其他指示）
```

#### Operable（可操作）

```
[ ] 所有功能可以用 keyboard 操作（唔好靠 mouse）
[ ] 焦点順序合理（logical tab order）
[ ] 焦点可見（focus indicator 唔好移除）
[ ] 網頁有 skip navigation link（讓 keyboard user 跳過導航）
[ ] 任何 timed content 可以暫停 / 延長
[ ] 唔好有 seizure-inducing 閃光（> 3次/秒）
[ ] 連結有 descriptive text（唔好「click here」）
```

#### Understandable（可理解）

```
[ ] 語言有聲明（`<html lang="zh-Hant">`）
[ ] 避免奇怪 / 難讀嘅文字
[ ] 表單 labels 清晰，錯誤提示有說明
[ ] 頁面係咪 predictably 操作（導航 consistent）
```

#### Robust（穩健）

```
[ ] HTML 語義化（正確使用 heading、button、link）
[ ] ARIA 正確使用（但優先用 native HTML）
[ ] 網頁喺多個瀏覽器正常運作
[ ] 通過 WAVE / axe accessibility audit
```

### 工具

| 工具 | 用途 |
|------|------|
| **axe DevTools** | Browser extension，自動 accessibility 審計 |
| **WAVE** | Web accessibility evaluation tool |
| **Lighthouse** | 内置 accessibility score |
| **axe Auditor** | CI/CD 集成，自動 accessibility 測試 |

---

## Phase W13｜Social Sharing + Structured Data

### Open Graph（Facebook / LinkedIn / WhatsApp）

```html
<!-- 每個頁面必備 -->
<meta property="og:title" content="頁面標題">
<meta property="og:description" content="簡短描述（150-200字）">
<meta property="og:image" content="https://example.com/image.jpg">
<meta property="og:url" content="https://example.com/page">
<meta property="og:type" content="website">
<meta property="og:locale" content="zh_TW">
```

**⚠️ og:image 要求：**
- 尺寸：1200x630（最小 600x315）
- 格式：JPG / PNG / WebP
- 檔案大小：< 8MB

### Twitter Cards

```html
<!-- 如果要 Twitter 顯示富媒體 -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="標題">
<meta name="twitter:description" content="描述">
<meta name="twitter:image" content="https://example.com/image.jpg">
<meta name="twitter:site" content="@你的帳戶">
```

> 💡 如果 og tags 已經有 `og:title` / `og:description` / `og:image`，Twitter 會自動讀取，唔使重複。

### Structured Data（Schema.org）

> 幫助搜索引擎理解頁面內容，**直接影響 SEO**。

```html
<!-- Article（Blog post / 新聞）-->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "你的標題",
  "author": { "@type": "Person", "name": "作者名" },
  "datePublished": "2026-07-12",
  "image": "https://example.com/image.jpg"
}
</script>

<!-- Breadcrumb（麵包屑導航）-->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "首頁", "item": "https://example.com" },
    { "@type": "ListItem", "position": 2, "name": "文章", "item": "https://example.com/blog" }
  ]
}
</script>
```

**常用 Schema Types：**

| 頁面類型 | Schema @type |
|---------|-------------|
| Blog 文章 | `Article` |
| 產品頁面 | `Product` |
| 業務 | `LocalBusiness` |
| 視頻 | `VideoObject` |
| 事件 | `Event` |
| 常見問題 | `FAQPage` |

**工具：** Google Schema Markup Helper / Rich Results Test

---

## Phase W14｜i18n（多語言）

> ⚠️ **唔好靠 Google Translate——自己翻譯或請專業譯者。**

### i18n 策略決策

| 策略 | 幾時用 | 點搞 |
|------|--------|------|
| **Subdirectory** | 大多數情況 | `example.com/zh/` + `example.com/en/` |
| **Subdomain** | 大型、多地區 | `zh.example.com` + `en.example.com` |
| **ccTLD** | 地區差異大 | `example.hk` + `example.tw` |
| **Parameter** | 過渡期（不推薦）| `example.com?lang=zh` |

### 框架推薦

```
- Next.js → next-intl / next-translate
- Astro → built-in i18n
- Nuxt.js → @nuxtjs/i18n
```

### i18n 必做清單

```
[ ] HTML lang attribute 正確（`<html lang="zh-Hant">`）
[ ] URL 包含語言（`/zh/about`）
[ ] Navigation language switcher（每個頁面都要有）
[ ] Date / Time / Currency 格式化（locale-aware）
[ ] RTL 語言支持（如果支持阿拉伯文 / 希伯來文）
[ ] 翻譯唔好硬編碼（所有 text 放 translation files）
[ ] Metadata（title / description）每個語言版本都要有
[ ] hreflang tags（告訴搜索引擎邊個語言版本係主頁）
[ ] Sitemap 包含所有語言版本
```

### hreflang 設置

```html
<link rel="alternate" hreflang="zh-TW" href="https://example.com/zh/">
<link rel="alternate" hreflang="en" href="https://example.com/en/">
<link rel="alternate" hreflang="x-default" href="https://example.com/">
```

---

## Phase W15｜PWA（Progressive Web App）

> ⚠️ **PWA 適合需要 mobile app 體驗但唔想整原生 app 嘅項目。**

### PWA 核心要素

```
✅ 必備（安裝 + 离线可用）：
  - manifest.json（定義 app name / icon / theme color）
  - Service Worker（缓存策略 + offline fallback）
  - HTTPS（PWA 強制要求）
  - 192x192 + 512x512 icons

✅ 建議（更好體驗）：
  - Push notifications（需要用戶授權）
  - Background sync（离线時提交數據，online 時同步）
  - Web app install banner（瀏覽器提示安裝）
```

### manifest.json

```json
{
  "name": "我的網站",
  "short_name": "網站",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0070f3",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### Service Worker 策略

| 策略 | 適用場景 |
|------|----------|
| **Cache First** | 静态資源（CSS / JS / 圖）——fast，唔更新 |
| **Network First** | API 數據——確保最新，但慢 |
| **Stale-While-Revalidate** | 两全其美——先cache顯示，背景更新 |
| **Network Only** | 實時數據（股票、消息）|

---

## Phase W16｜Legal（隱私政策 + 條款）

> ⚠️ **唔好抄網上模板——用律師或專用工具生成，確保符合 GDPR / 香港私隱條例。**

### 必備頁面

| 頁面 | 幾時需要 |
|------|----------|
| **Privacy Policy** | 任何收集用戶數據嘅網站（分析、cookies、forms）|
| **Terms of Service** | 提供服務 / 產品嘅網站 |
| **Cookie Consent** | 用 cookies（幾乎所有網站）|
| **Accessibility Statement** | 大型網站（歐盟 EAA 要求）|

### Cookie Consent 注意事項

```
✅ 要做：
  - 明確說明用咗咩 cookies
  - 給用戶選擇（拒絕 / 接受）
  - 用戶可以隨時更改偏好
  - 拒絕唔影響基本功能

❌ 唔好：
  - 預設全部 accept（GDPR 要求明示同意）
  - 將 accept button 設計得特別明顯但 reject 好難搵
  - 話拒絕 cookies 會影響網站正常運作
```

### 推薦工具

| 工具 | 用途 |
|------|------|
| **OneTrust / Cookiebot** | Cookie consent management |
| **Termly** | Privacy policy / Terms 生成 + consent |
| **Iubenda** | 隱私政策 / Terms / Cookie solution |

---

## 📋 快速參考卡

### 最小可行網站必備

```
域名 → DNS → SSL ✅
静态托管 ✅
HTTPS ✅
基本 SEO（title + meta）✅
Mobile responsive ✅
Performance（< 3s load）✅
Uptime monitoring ✅
```

### 完整 production 網站必備

```
最小可行網站所有 +
Backend + Database ✅
登入 + 權限控制 ✅
安全 headers + Rate limiting ✅
完整 SEO（sitemap + robots + structured data）✅
Analytics ✅
Error tracking ✅
CI/CD ✅
Preview deployments ✅
備份 + 恢復流程 ✅
Secrets 管理 ✅
Accessibility（WCAG 2.2 AA）✅
Open Graph tags ✅
```

---

## 🔗 相關文檔

| 文檔 | 關係 |
|------|------|
| `sop-master.md` | 通用軟件設計框架（先讀）|
| `memory/tool-playbook.md` | 工具使用心得 |
| `memory/SYSTEM-LESSONS.md` | 踩坑 lessons |

---

*Last updated: 2026-07-12*
*資料來源：Web Dev Best Practices 2026 + WCAG 2.2 + PWA Checklist + SEO Guides*
*用途：網站建設思考框架，係 `sop-master.md` 嘅網站專用補充*
