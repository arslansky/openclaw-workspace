# Heartbeat Checklist（每次 heartbeat 檢查）

## 1. Toolbox Sync 狀態（每 2 天）
- 檢查 `toolbox-sync.log` 有冇新 entries
- 檢查 `toolbox_repo/.toolbox-version` vs GitHub remote 版本
- 如果落後 > 2 天，通知用戶話 toolbox 可能需要手動 sync

## 2. GitHub Backup 健康（每週一）
- 檢查 `openclaw-workspace` repo 係咪仍然 404
- 如果仍然 404，通知用戶話 backup 已斷 7 天

## 3. VM 可達性（每週）
- SSH 到 Hermes（161.118.247.199）確認 alive
- SSH 到 ZO（ts8.zocomputer.io:10661）確認 alive
  - **⚠️ 已知問題（2026-07-11）：port 10661 connection refused，VM 可能已關閉或 SSH port 變動**
  - 如失敗 → 立即喺 HEARTBEAT.md 記錄，並通知用戶

## 4. 待辦跟進
- [ ] ZO VM bootstrap toolbox
- [ ] openclaw-workspace repo 修復
- [ ] hermes bot token 用途確認
- [ ] janzaibot 用途確認
- [ ] know2learn forum ingress 修復

## 5. 架構文件更新
- 如果有任何VM/bots/scripts/cron變動，更新 ARCHITECTURE.md 並 sync 到 toolbox repo
- 方法：cp ~/.openclaw/workspace/ARCHITECTURE.md /tmp/toolbox/ && cd /tmp/toolbox && git add -A && git commit -m "docs: update ARCHITECTURE.md" && git push

## 6. ACE Feedback Loop（每次 heartbeat）
**目標：每個 script/tool 執行完，自動寫 log → 每週六做一次 Grow-and-Refine**
- 每個 script 執行完 → 必須追加一行到 `memory/tool-log.jsonl`
  - 格式：`{"script": "...", "task": "...", "success": true/false, "duration_sec": N, "note": "..."}`
- Log 格式嚴格跟 ACE：每條 entry 包含 script name + task + success + feedback note
- 禁止：只寫「OK」或空白，必須有起碼 task description
- 工具：`memory/tool-log.jsonl`（JSONL 格式，行追加）
- 每週六 inbox review 時 → 順便做一次 tool-playbook.md 更新

## 7. Ops Log Safety Net（每次 heartbeat）
- 檢查 `memory/ops/` 有冇今日嘅 file（`YYYY-MM-DD.md`）
- 如果今日做過操作（mv / rm / cp / config change）但冇 ops log → 報告「可能漏咗記錄操作」
- 如果今日冇做任何操作 → 正常，skip
