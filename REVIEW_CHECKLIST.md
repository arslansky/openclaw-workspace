# Code Review Checklist

## 審核標準（Reviewer 必須檢查）

### 1. 正確性 (Correctness)
- [ ] 邏輯是否正確？有冇明顯 bug？
- [ ] Corner cases 有冇處理？（空輸入、邊界值、異常狀態）
- [ ] 並發/競態條件有冇考慮？（如果適用）

### 2. 健壯性 (Robustness)
- [ ] Error handling 是否完整？
- [ ] 有冇 try-catch / 錯誤碼 / 日誌記錄？
- [ ] 輸入驗證（validation）是否足夠？

### 3. 可讀性 (Readability)
- [ ] 變數/函數命名是否清晰？
- [ ] 有冇過長函數（>50 行要考慮拆分）？
- [ ] 註解是否足夠解釋「為什麼」而非「做什麼」？

### 4. 效能 (Performance)
- [ ] 有冇明顯效能瓶頸？（O(n²) 當 n 大時）
- [ ] 有冇不必要嘅資源消耗？（重複計算、記憶體洩漏）

### 5. 安全性 (Security)
- [ ] 有冇 SQL injection / XSS / 命令注入風險？
- [ ] 敏感數據有冇妥善處理？

## Reviewer 回覆格式

必須以以下格式結尾：

```
## REVIEW CONCLUSION

**STATUS:** [APPROVED / NEEDS_FIX]

**理由：** [簡短說明，如果 NEEDS_FIX 要列出具體問題]

**共識達成：** [YES / NO - 如果作者已修復並解釋]
```

## Marker 格式

審核通過後，作者喺檔案結尾加：

```
<!-- REVIEWED: YYYY-MM-DD by [reviewer-model] -->
<!-- REVIEW_CHECKSUM: [檔案內容 hash 或簡短描述] -->
```

## 流程

1. 作者寫完 code
2. 開 reviewer session，帶 checklist + 檔案內容
3. Reviewer 逐項檢查，給結論
4. 如果 NEEDS_FIX，作者修完再開 reviewer 驗收
5. 如果 APPROVED，作者蓋 marker
