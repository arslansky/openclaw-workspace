# Task Registry｜TRAP-style 任務追蹤

> 雙層規劃：Abstract Plan（高層） + Subtasks（底層 field mapping）
> 防止 plan drift，保持長週期任務方向正確

---

## Active Tasks（進行中）

| Task ID | Abstract Plan | Phase | Status | Last Update |
|---|---|---|---|---|
| sys-audit-20260711 | OpenClaw 全系統審計（ACE/SICA/TRAP 框架） | phase_2 | 🟡 in_progress | 2026-07-11 |

---

## Completed Tasks（已完成）

| Task ID | Abstract Plan | Duration | Outcome | Notes |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Phase Mapping（常用欄位名）

```
phase_N_name
  → phase_N_checklist: [...]
  → phase_N_status: pending|in_progress|done|blocked
  → phase_N_blocker: ...
  → phase_N_notes: ...
```

---

## 操作規則

1. **每個複雜任務** → 建立 `active/<task-id>/` folder
2. **高層目標** → `_plan.md`（Abstract Plan）
3. **子任務追蹤** → `_subtasks.md`（Field Mapping）
4. **完成後** → 移動去 `completed/`，更新呢份 registry
5. **Blocker 出現** → 立即寫入 `phase_N_blocker`，及時上報

---

*Created: 2026-07-11 · TRAP-inspired structure*
