-- YouTube 影片追查表
-- Option A: 淨係 db schema + helper script

CREATE TABLE IF NOT EXISTS yt_projects (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    編號        TEXT    NOT NULL UNIQUE,   -- 流水號 e.g. YT-001
    題材        TEXT    NOT NULL,           -- 影片主題
    字幕        TEXT    DEFAULT NULL,       -- 字幕狀態: pending / done / file_path
    摘要        TEXT    DEFAULT NULL,       -- 摘要狀態: pending / done / file_path
    video_id    TEXT    DEFAULT NULL,       -- YouTube video ID
    url         TEXT    DEFAULT NULL,       -- 原始 URL
    duration    TEXT    DEFAULT NULL,       -- 時長 e.g. "24m 19s"
    notes       TEXT    DEFAULT NULL,       -- 備註
    created_at  TEXT    DEFAULT (datetime('now')),
    updated_at  TEXT    DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_yt_編號 ON yt_projects(編號);
CREATE INDEX IF NOT EXISTS idx_yt_題材 ON yt_projects(題材);
