# 2026-07-16 Dreaming Test

## 今日發生嘅事
- 討論咗 OpenClaw memory system 設定問題
- memorySearch 因為 OpenAI API key 未配對 agent 而 fail
- 用 Plan B 轉 provider=none（純 keyword FTS）
- rebuild index 成功
- 啟用 Active Memory plugin，arslansky-agent 適用
- 啟用 Dreaming in memory-core，每日 3am 自動 sweep
- 試行 Dreaming 但短期記憶庫空的
- 手動寫 daily notes 希望 promotion 可以 work

## 技術決策
- memorySearch provider: OpenAI → none（因 API key 問題）
- Active Memory 同 Dreaming 都係第一次開
- 目前用純 keyword FTS search，冇 vector embedding
