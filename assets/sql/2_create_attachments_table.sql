CREATE TABLE attachments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    note_id INTEGER,
    type TEXT,
    file_path TEXT,
    FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
  );