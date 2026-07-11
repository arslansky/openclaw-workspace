# Subtasks｜Field-Mapped 子任務追蹤

**Task ID:** __TASKID__
**Last Updated:** YYYY-MM-DD

---

## Phase 1: __PHASE_1_NAME__

**Status:** 🟡 in_progress

| Field | Value | Updated |
|---|---|---|
| `p1_step_a` | ✅ done | YYYY-MM-DD |
| `p1_step_b` | 🔄 in_progress | YYYY-MM-DD |
| `p1_step_c` | ⬜ pending | — |

**p1_blocker:** __BLOCKER_IF_ANY__

---

## Phase 2: __PHASE_2_NAME__

**Status:** ⬜ pending

| Field | Value | Updated |
|---|---|---|
| `p2_step_d` | ⬜ pending | — |
| `p2_step_e` | ⬜ pending | — |

**p2_blocker:** none

---

## Phase 3: __PHASE_3_NAME__

**Status:** ⬜ pending

| Field | Value | Updated |
|---|---|---|
| `p3_step_f` | ⬜ pending | — |
| `p3_step_g` | ⬜ pending | — |

---

## 失敗模式日誌（Failure Mode Log）

每次失敗要記錄：
```
[YYYY-MM-DD HH:MM] pX_step_Y FAILED
Reason: __
Pattern: __  （myopic / plan_drift / short_term_bias / other）
Root Cause: __
Fix Applied: __
```
