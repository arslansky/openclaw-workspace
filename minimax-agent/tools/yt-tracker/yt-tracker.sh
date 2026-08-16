#!/usr/bin/env python3
"""yt-tracker.sh — YT 影片追查 helper（Python + sqlite3）"""
import sqlite3, sys, os

DB = os.path.expanduser("~/memory/progress-tracker.db")
conn = sqlite3.connect(DB)
cur = conn.cursor()

cmd = sys.argv[1] if len(sys.argv) > 1 else ""
args = sys.argv[2:]

def rows(query, params=()):
    cur.execute(query, params)
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    return cols, rows

def print_table(cols, rows):
    widths = [max(len(str(c)), max((len(str(r[i])) for r in rows), default=0)) for i, c in enumerate(cols)]
    header = " | ".join(c.ljust(widths[i]) for i, c in enumerate(cols))
    sep = "-+-".join("-" * w for w in widths)
    print(header)
    print(sep)
    for r in rows:
        print(" | ".join(str(r[i]).ljust(widths[i]) for i in range(len(cols))))

if cmd == "list":
    cols, rows = rows("SELECT 編號,題材,字幕,摘要,duration,updated_at FROM yt_projects ORDER BY id DESC")
    if rows:
        print_table(cols, rows)
    else:
        print("(empty)")

elif cmd == "add":
    if len(args) < 2:
        print("Usage: add <編號> <題材> [url]")
    else:
        cur.execute("INSERT INTO yt_projects (編號,題材,url) VALUES (?,?,?)", args[:2] + [args[2] if len(args)>2 else None])
        conn.commit()
        print(f"Added: {args[0]} | {args[1]}")

elif cmd == "done":
    if len(args) < 3:
        print("Usage: done <編號> <字幕> <摘要>")
    else:
        cur.execute("UPDATE yt_projects SET 字幕=?, 摘要=?, updated_at=datetime('now') WHERE 編號=?", args[1:] + [args[0]])
        conn.commit()
        print(f"Marked done: {args[0]}")

elif cmd == "update":
    if len(args) < 3:
        print("Usage: update <編號> <field> <value>")
    else:
        cur.execute(f"UPDATE yt_projects SET {args[1]}=?, updated_at=datetime('now') WHERE 編號=?", [args[2], args[0]])
        conn.commit()
        print(f"Updated: {args[0]}.{args[1]} = {args[2]}")

elif cmd == "get":
    if not args:
        print("Usage: get <編號>")
    else:
        cols, rows = rows("SELECT * FROM yt_projects WHERE 編號=?", [args[0]])
        if rows:
            for r in rows:
                for c, v in zip(cols, r):
                    print(f"  {c}: {v}")
        else:
            print("Not found")

elif cmd == "pending":
    cols, rows = rows("SELECT 編號,題材,字幕,摘要 FROM yt_projects WHERE 字幕!='done' OR 摘要!='done' ORDER BY id DESC")
    if rows:
        print_table(cols, rows)
    else:
        print("(all done)")

else:
    print("Commands: list | add | done | update | get | pending")
