#!/usr/bin/env bash
# recall_snapshot.sh — Phase 4 of Plan B
#
# On SessionStart, read MEMORY.md's LAST_SNAPSHOT marker, find the
# corresponding snapshot, and emit a concise summary to stdout so the
# agent can immediately recall "what was I doing last session?"
#
# Output is meant to be consumed by the agent's context-loader.
# Format: structured text sections, exit 0 always (recall is best-effort).

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(cd "$DIR/.." && pwd)"
MEMORY="$WORKSPACE/MEMORY.md"

if [[ ! -f "$MEMORY" ]]; then
  echo "recall_snapshot: no MEMORY.md at $MEMORY" >&2
  exit 0
fi

# Extract LAST_SNAPSHOT timestamp
LAST_TS=$(grep -m1 "^<!-- LAST_SNAPSHOT=" "$MEMORY" | sed 's/.*LAST_SNAPSHOT=\([0-9]*\) -->.*/\1/' || echo "")

if [[ -z "$LAST_TS" ]]; then
  echo "=== RECALL_SNAPSHOT ==="
  echo "Status: no prior snapshot (fresh workspace)"
  echo "=== END ==="
  exit 0
fi

# Find the corresponding memory snapshot file
TODAY_DIR="$WORKSPACE/memory/$(date +%Y-%m-%d)"
SNAP_FILE="$TODAY_DIR/snapshots/memory-${LAST_TS}.md"

# If not in today's dir, search recent dirs
if [[ ! -f "$SNAP_FILE" ]]; then
  # Search backward up to 7 days
  for offset in 1 2 3 4 5 6 7; do
    PAST_DATE=$(date -d "${offset} days ago" +%Y-%m-%d 2>/dev/null || date -v -${offset}d +%Y-%m-%d 2>/dev/null || echo "")
    if [[ -n "$PAST_DATE" ]]; then
      CAND="$WORKSPACE/memory/$PAST_DATE/snapshots/memory-${LAST_TS}.md"
      if [[ -f "$CAND" ]]; then
        SNAP_FILE="$CAND"
        break
      fi
    fi
  done
fi

echo "=== RECALL_SNAPSHOT ==="
echo "Last snapshot TS: $LAST_TS"
echo "Snapshot file: ${SNAP_FILE#$WORKSPACE/}"

if [[ ! -f "$SNAP_FILE" ]]; then
  echo "Status: marker present but file not found (older than 7 days or moved)"
  echo "=== END ==="
  exit 0
fi

# Extract the marker footer from snapshot (last 8 lines)
echo ""
echo "--- Snapshot footer (last 8 lines) ---"
tail -8 "$SNAP_FILE" | grep "^<!--" || echo "(no markers)"
echo ""

# Read last 30 lines of daily log if exists
DAILY_DIR=$(dirname "$(dirname "$SNAP_FILE")")
DAILY="$DAILY_DIR/../$(basename "$DAILY_DIR").md"
if [[ -f "$DAILY" ]]; then
  echo "--- Daily log entries since last snapshot ---"
  # Find the snapshot_ts_human marker from snapshot footer
  TS_HUMAN=$(grep "^<!-- last_snapshot_ts=" "$SNAP_FILE" | sed 's/.*last_snapshot_ts=\([^ ]*\) -->.*/\1/' || echo "")
  if [[ -n "$TS_HUMAN" ]]; then
    # Use sed to find the matching line, then emit lines from there to next blank+## block
    # Pattern: emit everything from the matched snapshot block to end of daily log (or limit 25 lines)
    LINE_NUM=$(grep -n "## snapshot @${TS_HUMAN}" "$DAILY" | head -1 | cut -d: -f1 || echo "")
    if [[ -n "$LINE_NUM" ]]; then
      tail -n +"$LINE_NUM" "$DAILY" | head -25
    else
      tail -15 "$DAILY"
    fi
  else
    tail -15 "$DAILY"
  fi
  echo "---"
fi

echo ""
echo "Action hint: if last snapshot is < 24h old, treat this session as CONTINUATION."
echo "              If >= 24h old, treat as FRESH (this is reference material)."
echo "=== END ==="
exit 0