# Deleted Files in Git (2026-07-05)
# Total: 1332 deleted files

## agents_backup/agents/knowledge/agent/ (11 files)
agents_backup/agents/knowledge/agent/auth-profiles.json
agents_backup/agents/knowledge/agent/models.json
agents_backup/agents/knowledge/agent/plugins/arcee/catalog.json
agents_backup/agents/knowledge/agent/plugins/deepseek/catalog.json
agents_backup/agents/knowledge/agent/plugins/kimi/catalog.json
agents_backup/agents/knowledge/agent/plugins/minimax/catalog.json
agents_backup/agents/knowledge/agent/plugins/moonshot/catalog.json
agents_backup/agents/knowledge/agent/plugins/openrouter/catalog.json

## agents_backup/agents/knowledge/sessions/ (~1260+ files)
Session files from agents/knowledge/sessions/ including:
- 00b47a44-7c4d-4f3d-ae3a-12dc3b2f7c44.jsonl.reset.2026-05-31T07-47-43.715Z
- 014f23ad-b2bb-4850-b5de-6502a009ab0e.jsonl (+ trajectory files)
- 076657e4-5f06-4b79-8c6d-c9e75ab37437.jsonl (+ trajectory files)
- ... (100s more)

## agents_backup/agents/main/agent/ (12 files)
agents_backup/agents/main/agent/auth-profiles.json
agents_backup/agents/main/agent/auth-state.json
agents_backup/agents/main/agent/config.json
agents_backup/agents/main/agent/model.json
agents_backup/agents/main/agent/models.json
agents_backup/agents/main/agent/plugins/*/catalog.json (7 plugins)

## agents_backup/agents/main/sessions/ (~400+ session files)
agents_backup/main/sessions/*.jsonl (+ trajectory files)

## para/archives/scripts/ (2 files)
para/archives/scripts/tg_bot_zeabur01_simple.py
para/archives/scripts/tg_bot_zeabur01_v2.py

## Summary
Total deleted: 1332 files
These are old session backup files that were deleted from disk but not from git index.
They are NOT pushed to GitHub yet - they only exist in local git state.
GitHub repo is clean.

## Recommendation
To fix local git state, run:
cd ~/.openclaw/workspace
git add -A
git commit -m "Remove old agents_backup files"
git push origin master

OR if you want to keep the backup folder in git:
git checkout -- agents_backup/
