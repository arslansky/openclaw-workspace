#!/usr/bin/env bash
# pre_compact_snapshot.sh — Phase 1+2 of Plan B
# 
# Captures a snapshot of MEMORY.md + daily log when context pressure
# is high (default: >= 70%) or when OpenClaw triggers PreCompact event.
#
# Usage:
#   pre_compact_snapshot.sh                           # default trigger
#   pre_compact_snapshot.sh --threshold 80            # custom %
#   pre_compact_snapshot.sh --force                   # skip pressure check
#   pre_compact_snapshot.sh --reason "explicit ask"   # custom reason
#
# Environment variables (set by OpenClaw or shell):
#   OPENCLAW_EVENT       - "PreCompact" | "Stop" | "manual" (default: manual)
#   OPENCLAW_PRESSURE    - 0-100 percentage (default: 0 = auto-detect)
#   OPENCLAW_REASON      - reason string (default: from arg)
#
# Exit codes:
#   0  = snapshot written successfully
#   2  = usage error
#   4  = MEMORY.md not found
#   5  = write error

set -euo pipefail

# ─────────────────────────── Args ───────────────────────────
THRESHOLD=70
FORCE=0
REASON="${OPENCLAW_REASON:-manual}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="${2:-70}"; shift 2 ;;
    --force)     FORCE=1; shift ;;
    --reason)    REASON="${2:-manual}"; shift 2 ;;
    -h|--help)
      sed -n '2,28p' "$0"
      exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

# ─────────────────────────── Paths ───────────────────────────
DIR="$(cd "$(dirname "$0")" && pwd)"
# Workspace is parent of hooks/
WORKSPACE="$(cd "$DIR/.." && pwd)"

MEMORY="$WORKSPACE/MEMORY.md"
DAILY="$WORKSPACE/memory/$(date +%Y-%m-%d).md"
TODAY_DIR="$WORKSPACE/memory/$(date +%Y-%m-%d)"
SNAP_DIR="$TODAY_DIR/snapshots"

mkdir -p "$SNAP_DIR"

[[ -f "$MEMORY" ]] || { echo "FATAL: MEMORY.md not found at $MEMORY" >&2; exit 4; }

# ─────────────────────────── Pressure detection ───────────────────────────
PRESSURE="${OPENCLAW_PRESSURE:-0}"
EVENT="${OPENCLAW_EVENT:-manual}"

# If explicit PreCompact event OR force flag, always proceed
if [[ "$FORCE" != "1" && "$EVENT" != "PreCompact" ]]; then
  if [[ "$PRESSURE" == "0" ]]; then
    # Try to auto-detect from disk (size of transcript log if exists)
    LOG="$WORKSPACE/memory/.transcript_size"
    if [[ -f "$LOG" ]]; then
      PRESSURE=$(cat "$LOG" 2>/dev/null || echo 0)
    fi
  fi
  if [[ "$PRESSURE" -lt "$THRESHOLD" ]]; then
    echo "SKIP: pressure=$PRESSURE% < threshold=${THRESHOLD}%"
    exit 0
  fi
fi

TS=$(date +%s)
TS_HUMAN=$(date +%Y-%m-%d_%H%M%S)

# ─────────────────────────── Snapshot files ───────────────────────────
echo "==> snapshot @${TS_HUMAN} (pressure=${PRESSURE}% event=${EVENT} reason=${REASON})"

# 1. Copy MEMORY.md with marker appended
MEM_SNAP="$SNAP_DIR/memory-${TS}.md"
cp "$MEMORY" "$MEM_SNAP"
{
  echo ""
  echo "<!-- LAST_SNAPSHOT=${TS} -->"
  echo "<!-- last_snapshot_ts=${TS_HUMAN} -->"
  echo "<!-- context_pressure=${PRESSURE}% -->"
  echo "<!-- trigger_event=${EVENT} -->"
  echo "<!-- reason=${REASON} -->"
} >> "$MEM_SNAP"
echo "    ✓ MEMORY.md → $MEM_SNAP"

# 2. Copy daily log if it exists
DAILY_SNAP=""
if [[ -f "$DAILY" ]]; then
  DAILY_SNAP="$SNAP_DIR/daily-${TS}.md"
  cp "$DAILY" "$DAILY_SNAP"
  echo "    ✓ daily log → $DAILY_SNAP"
fi

# 3. Auto-append entry to today's daily log
{
  echo ""
  echo "## snapshot @${TS_HUMAN}"
  echo ""
  echo "- **MEMORY.md snapshot**: \`${MEM_SNAP#$WORKSPACE/}\`"
  [[ -n "$DAILY_SNAP" ]] && echo "- **Daily log snapshot**: \`${DAILY_SNAP#$WORKSPACE/}\`"
  echo "- **Trigger**: event=\`${EVENT}\`, pressure=\`${PRESSURE}%\`, reason=\`${REASON}\`"
  echo ""
} >> "$DAILY"
echo "    ✓ appended entry to $DAILY"

# 4. Update LAST_SNAPSHOT marker in MEMORY.md header (lightweight, first line)
# Use sed to ensure only ONE marker exists
TMP=$(mktemp)
# Remove any existing LAST_SNAPSHOT line, then prepend fresh one
grep -v "^<!-- LAST_SNAPSHOT=" "$MEMORY" > "$TMP" || true
{
  echo "<!-- LAST_SNAPSHOT=${TS} -->"
  cat "$TMP"
} > "$MEMORY"
rm -f "$TMP"
echo "    ✓ updated LAST_SNAPSHOT marker in MEMORY.md"

# 5. Manifest
MANIFEST="$SNAP_DIR/manifest.jsonl"
{
  echo "{\"ts\":${TS},\"ts_human\":\"${TS_HUMAN}\",\"event\":\"${EVENT}\",\"pressure\":${PRESSURE},\"reason\":\"${REASON}\",\"mem\":\"${MEM_SNAP#$WORKSPACE/}\"${DAILY_SNAP:+, \"daily\":\"${DAILY_SNAP#$WORKSPACE/}\"}}"
} >> "$MANIFEST"

echo ""
echo "DONE: snapshot written. Trigger=${REASON}, pressure=${PRESSURE}%"
echo "Latest snapshot: $MEM_SNAP"
exit 0