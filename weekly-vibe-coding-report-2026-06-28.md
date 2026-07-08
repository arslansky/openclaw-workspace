# Vibe Coding 工具週報 — 2026-06-28 (Week 26)

> 🔥 每週知識整理任務 | 生成時間：2026-06-28 02:00 UTC

---

## 📋 執行摘要

- **檢查文件**: `vibe-coding-guide.md` 不存在於 workspace，本週報為獨立整理
- **重點工具**: Cursor、Claude Code、GitHub Copilot
- **新興趨勢**: Auto-review、Cloud Agents、Artifacts
- **定價變動**: 無重大變動，Cursor 維持 credit-based，Claude Code Pro $20/月

---

## 🔥 Cursor 最新動態 (June 2026)

### 重大更新

1. **Auto-review 智能審查系統** 🔥
   - 新推出的「分類器代理」自動評估操作風險
   - 低風險操作自動通過，高風險操作才會提示用戶
   - 僅約 7% 的對話會被打斷（企業客戶原本約 40%）
   - 分類器會返回解釋給父代理，讓其選擇更安全路徑

2. **Bugbot 3倍提速** 🔥
   - 審查時間從 ~5 分鐘降至 ~90 秒
   - 每次審查發現 bug 數量提升 10%（0.56 → 0.62）
   - 每次運行成本降低 ~22%
   - 由 Composer 2.5 驅動

3. **Cursor Automations 自動化**
   - `/automate` 技能：用自然語言創建自動化
   - Slack emoji 觸發器
   - 5 個新的 GitHub 觸發器（Issue comment、PR review 等）
   - Computer use tool：雲端代理可生成演示/工件

4. **Cloud Subagents 雲端子代理**
   - `/in-cloud` 啟動獨立 VM 子代理
   - `/babysit` 讓雲端代理持續迭代準備 PR
   - 本地與雲端無縫切換
   - 雲端環境設置 <10 分鐘，可保存快照

5. **Design Mode 改進**
   - 多選元素：同時選擇多個 UI 元素進行批量修改
   - 語音輸入：通過語音描述設計變更

6. **Customize 頁面**
   - 統一管理 plugins、skills、MCPs、subagents、rules
   - 支持 Team Marketplace（GitLab/BitBucket/Azure DevOps）
   - Plugin canvases：預建模板（Hex Canvas、Atlassian Canvas）

### 定價 (2026)
- **Free**: 2,000 completions/月
- **Pro**: $20/月（500 premium requests）
- **Business**: $40/用戶/月
- 第三方模型：$1.25/M input, $6/M output（不計入配額）

---

## 🔥 Claude Code 最新動態 (Week 22-26, June 2026)

### 重大更新

1. **Claude Opus 4.8 發布** 🔥
   - 新默認模型（Max、Team Premium、Enterprise）
   - 默認 high effort，支持 `/effort xhigh`
   - Fast mode：$10/$50 per MTok

2. **Artifacts 功能** 🔥
   - 將會話輸出轉為實時可分享頁面
   - 在 claude.ai 上實時更新
   - Team 和 Enterprise 計劃 beta 中

3. **Auto Mode 擴展**
   - 現支持 Pro 計劃（Week 21）
   - 擴展至 Bedrock、Vertex、Foundry 第三方提供商（Week 23）
   - 用背景安全檢查替代權限提示

4. **/rewind 命令** 🔥
   - 恢復 `/clear` 之前的對話
   - 解決了誤清對話的問題

5. **Dynamic Workflows 動態工作流**
   - 從腳本編排數十至數百個子代理
   - 適合大規模並行任務

6. **Security-guidance Plugin**
   - 實時審查 Claude 的更改是否存在漏洞
   - 邊寫邊檢查

7. **/ultrareview 雲端代碼審查**
   - 雲端 bug 獵人代理群
   - 自動將發現的問題返回 CLI/Desktop

8. **其他實用更新**
   - `claude mcp login`：從 shell 認證 MCP 服務器
   - Shell mode 響應命令輸出（`! npm test` 自動解釋）
   - Background subagents 在主會話顯示權限提示
   - `/cd` 切換工作目錄不重建 prompt cache
   - `--safe-mode` 禁用所有自定義設置進行故障排除
   - `fallbackModel` 配置最多 3 個備用模型

### 定價 (2026)
- **Pro**: $20/月（包含 Claude Code）
- **Max**: $100/月
- **Team**: $25/用戶/月
- **Enterprise**: $200/用戶/月
- API 費率：Sonnet $3/$15, Opus $5/$25 per MTok

---

## 🔥 GitHub Copilot 最新動態 (2026)

### 重大更新

1. **Copilot Workspace** 🔥
   - 全項目級助手：用自然語言規劃、編寫、完善整個應用
   - 自動版本化更改上下文和歷史
   - 一鍵創建 PR
   - GitHub 移動應用直接打開

2. **Copilot Memory**
   - 推斷和存儲倉庫有用信息
   - 雲端代理和代碼審查可利用這些信息提升輸出質量

3. **Prompt Files**
   - 可重用的提示指令文件
   - Markdown 格式，存儲在工作區

4. **定價變動**
   - 2026年6月1日起：代碼審查工作流消耗 GitHub Actions 分鐘數
   - 企業管理員需顯式啟用「GitHub AI Credits paid usage」
   - 新策略：允許無 Copilot 許可的成員使用代碼審查

---

## 🆕 新興 Vibe Coding 工具

| 工具 | 類型 | 特點 | 狀態 |
|------|------|------|------|
| **Lovable** | App Builder | 自然語言構建應用 | 活躍 |
| **Replit** | App Builder + AI | 全棧開發環境 | 活躍 |
| **v0 by Vercel** | App Builder | 前端設計 + 代碼生成 | 活躍 |
| **Windsurf AI** | AI Assistant | 類 Cursor 的 AI 編輯器 | 活躍 |
| **Gemini CLI** | AI Assistant | Google 的 CLI 工具 | 活躍 |
| **OpenAI Codex** | AI Assistant | OpenAI 的編碼代理 | 活躍 |

---

## 📊 工具比較表 (2026-06)

| 特性 | Cursor | Claude Code | GitHub Copilot |
|------|--------|-------------|----------------|
| **類型** | AI 編輯器 | CLI/終端代理 | IDE 插件/Workspace |
| **定價(個人)** | $20/月 | $20/月 | $10/月 |
| **定價(團隊)** | $40/用戶 | $25/用戶 | $19/用戶 |
| **模型** | 多模型 | Claude Opus/Sonnet | GPT-4o/Claude |
| **Auto Mode** | ✅ Auto-review | ✅ Auto mode | ✅ (部分) |
| **Cloud Agents** | ✅ /in-cloud | ✅ Background | ✅ Copilot Workspace |
| **Subagents** | ✅ | ✅ (5層) | ❌ |
| **MCP Support** | ✅ | ✅ | ❌ |
| **Artifacts** | ❌ | ✅ (Beta) | ❌ |
| **Code Review** | ✅ Bugbot | ✅ /ultrareview | ✅ |
| **Design Mode** | ✅ (Browser) | ❌ | ❌ |
| **語音輸入** | ✅ | ❌ | ❌ |
| **平台** | Desktop/Web | CLI/Desktop/Web | IDE/Web |

---

## 🚨 重要趨勢觀察

1. **Agent 自主權成為競爭焦點**
   - Cursor 的 Auto-review 和 Claude Code 的 Auto mode 都在減少用戶打斷
   - 從「開關」轉向「刻度盤」的自主權控制

2. **雲端代理興起**
   - Cursor Cloud Subagents、Claude Code Background agents
   - 隔離長時間運行任務，保持本地響應

3. **自動化工作流**
   - Cursor Automations、Claude Code Dynamic Workflows
   - 從「輔助編碼」轉向「自動化開發流程」

4. **Apple 開始審查 Vibe-coded Apps**
   - 平台守門人開始執行質量標準
   - 組織需要內部治理 AI 生成代碼

---

## 📝 待辦事項

- [ ] 創建/更新 `vibe-coding-guide.md` 完整指南文件
- [ ] 追蹤 Windsurf AI 和 Gemini CLI 的最新動態
- [ ] 監控 OpenAI Codex 的公開發布進展
- [ ] 下週檢查是否有新的定價變動

---

*本報告由每週知識整理任務生成 | 下次檢查：2026-07-05*
