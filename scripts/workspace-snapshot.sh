#!/bin/bash
# Workspace Snapshot Diff — 每日自動 detect 檔案變化
# 用法：bash scripts/workspace-snapshot.sh
# 排程：每日 04:05 cron（backup 之後）
# 依賴：無

WORKSPACE="/home/ubuntu/.openclaw/workspace"
SNAPSHOT_DIR="/home/ubuntu/.openclaw/workspace/memory/ops/snapshots"
OPS_LOG="/home/ubuntu/.openclaw/workspace/memory/ops/$(date +%Y-%m-%d).md"
TODAY_SNAPSHOT="$SNAPSHOT_DIR/snapshot-$(date +%Y-%m-%d).txt"
YESTERDAY_SNAPSHOT="$SNAPSHOT_DIR/snapshot-$(date +%Y-%m-%d -d yesterday).txt"

mkdir -p "$SNAPSHOT_DIR"

# Take today's snapshot (excluding .git and large binary dirs)
find "$WORKSPACE" -not -path "*/.git/*" -not -path "*/images/*" -not -path "*/evie-gallery/*" -not -path "*/media/*" -not -path "*/toolbox_repo/*" -not -path "*minimax-agent/repos/*" -not -name "*.png" -not -name "*.jpg" -not -name "*.pdf" -type f | sort > "$TODAY_SNAPSHOT"

# If yesterday's snapshot doesn't exist, just save today and exit
if [ ! -f "$YESTERDAY_SNAPSHOT" ]; then
    echo "[snapshot] First run — saved today's snapshot only" >> "$SNAPSHOT_DIR/snapshot.log"
    exit 0
fi

# Compare
NEW_FILES=$(comm -13 "$YESTERDAY_SNAPSHOT" "$TODAY_SNAPSHOT")
REMOVED_FILES=$(comm -23 "$YESTERDAY_SNAPSHOT" "$TODAY_SNAPSHOT")

if [ -z "$NEW_FILES" ] && [ -z "$REMOVED_FILES" ]; then
    # No changes — normal
    echo "[snapshot] $(date +%Y-%m-%d) — no changes detected" >> "$SNAPSHOT_DIR/snapshot.log"
    exit 0
fi

# Changes detected — write to ops log
{
    echo ""
    echo "## $(date +%H:%M)｜Snapshot Diff（自動 detect）"
    if [ -n "$NEW_FILES" ]; then
        echo ""
        echo "**新增檔案：**"
        echo "$NEW_FILES" | sed 's/^/- /'
    fi
    if [ -n "$REMOVED_FILES" ]; then
        echo ""
        echo "**刪除檔案：**"
        echo "$REMOVED_FILES" | sed 's/^/- /'
    fi
    echo ""
    echo "> ⚠️ 以上係 snapshot diff 自動 detect 嘅變化。如果有操作但 ops log 冇記錄，請補寫。"
} >> "$OPS_LOG"

{
    echo "[snapshot] $(date +%Y-%m-%d) — changes detected → ops log appended"
    echo "  New: $(echo "$NEW_FILES" | wc -l) files"
    echo "  Removed: $(echo "$REMOVED_FILES" | wc -l) files"
} >> "$SNAPSHOT_DIR/snapshot.log"