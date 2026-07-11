# Abstract Plan｜OpenClaw 系統審計

**Task ID:** sys-audit-20260711
**Created:** 2026-07-11
**Status:** 🟡 in_progress

---

## 高層目標（One-liner）

> 用 ACE/SICA/TRAP 框架審計 OpenClaw 全系統，識別問題、記錄優化、建立長效追蹤機制。

---

## Phase Map（階段映射）

```
sys-audit-20260711
  → phase_1: [scan_scripts, check_vm, check_repos, check_bots]
  → phase_2: [fix_blockers, sync_missing, cleanup]
  → phase_3: [update_playbook, commit_changes]
```

---

## 為乜呢？（Why This Matters）

今日建立完整 feedback loop 系統，需要確認底層係乾淨、已知狀態。唔審計就係盲目優化。

---

## 成功標準（Done Criteria）

- [ ] 所有 blockers 記錄喺 tasks 並有跟進
- [ ] weekly-skills-backup.sh 同步問題修復
- [ ] ZO VM 連接問題確認原因
- [ ] 所有 scripts 狀態清晰
- [ ] tool-playbook.md 更新最新審計結果

---

## Blocker Summary（截至 2026-07-11 16:00）

| Item | Severity | Status |
|---|---|---|
| ZO VM port 10661 connection refused | 🔴 CRITICAL | blocker |
| janzaibot 用途未確認 | 🟡 MED | pending |
| ds bot 用途未確認 | 🟡 MED | pending |
| know2learn forum ingress 仍未修復 | 🟡 MED | known issue |
| weekly-skills-backup.sh 未進入 toolbox | 🟢 LOW | fix in progress |

