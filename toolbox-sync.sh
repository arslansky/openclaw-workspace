#!/usr/bin/env bash
# sync.sh — Bootstrap & sync bridge for toolbox
# Usage: bash sync.sh [hostname]
# hostname: openclaw | hermes (auto-detected if omitted)
set -euo pipefail

HOST="${1:-$(hostname)}"
TOOLBOX_DIR="$(cd "$(dirname "$0")" && pwd)"
OWN_DIR="$TOOLBOX_DIR/$HOST"
WORKSPACE_DIR="$HOME/.openclaw/workspace"

echo "=== Toolbox Sync ==="
echo "Host: $HOST"
echo "Toolbox: $TOOLBOX_DIR"
echo "Workspace: $WORKSPACE_DIR"
echo

# Verify this host is supported
if [ ! -d "$OWN_DIR" ]; then
    echo "ERROR: No scripts for host '$HOST'. Valid hosts: hermes, openclaw"
    exit 1
fi

# Sync owned scripts (hermes/ or openclaw/)
echo "[1/2] Syncing $HOST scripts..."
rsync -av --delete "$OWN_DIR/" "$WORKSPACE_DIR/scripts/"

# Sync shared scripts
echo "[2/2] Syncing shared scripts..."
if [ -d "$TOOLBOX_DIR/shared" ] && [ "$(ls -A "$TOOLBOX_DIR/shared")" ]; then
    for f in "$TOOLBOX_DIR/shared"/*; do
        [ -f "$f" ] && cp -f "$f" "$WORKSPACE_DIR/scripts/"
    done
fi

# Make all scripts executable
chmod +x "$WORKSPACE_DIR/scripts/"*.sh 2>/dev/null || true

# Tag version
cd "$TOOLBOX_DIR"
VERSION=$(git describe --always 2>/dev/null || echo "unknown")
echo "$VERSION" > "$WORKSPACE_DIR/.toolbox-version"
echo
echo "=== Done ==="
echo "Version: $VERSION"
echo "Updated: $(date '+%Y-%m-%d %H:%M:%S')"
