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

## 4. 待辦跟進
- [ ] ZO VM bootstrap toolbox
- [ ] openclaw-workspace repo 修復
- [ ] hermes bot token 用途確認
- [ ] janzaibot 用途確認
- [ ] know2learn forum ingress 修復

## 5. 架構文件更新
- 如果有任何VM/bots/scripts/cron變動，更新 ARCHITECTURE.md 並 sync 到 toolbox repo
- 方法：cp ~/.openclaw/workspace/ARCHITECTURE.md /tmp/toolbox/ && cd /tmp/toolbox && git add -A && git commit -m "docs: update ARCHITECTURE.md" && git push
