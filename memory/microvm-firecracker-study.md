# MicroVM / Firecracker 研究筆記（已過時）

> ⚠️ 此文件已過時。AWS Lambda MicroVMs 動態見 2026-06-26-27 已讀，但尚未轉換成 permanent note。
> 如果需要重新激活呢個研究綫索，從 sources/ 資料夾拎原始 PDF 重新消化。

---

## 🔥 AWS Lambda MicroVMs（2026-06-27）

- 基於 Firecracker 技術，提供 VM 級別隔離
- 狀態可保留長達 8 小時
- 適用場景：AI coding assistants、互動式代碼環境、數據分析平台、漏洞掃描器
- Firecracker 已支撐超過 15 萬億次每月 Lambda 函數調用
