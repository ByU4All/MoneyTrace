# migrate_friends.py
import sqlite3
from uuid import uuid4

DB_PATH = "moneytrace.db"


def column_exists(cur, table, column):
    cur.execute(f"PRAGMA table_info({table})")
    return column in [row[1] for row in cur.fetchall()]


def migrate():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # 1. Create friends table
    cur.execute("""
    CREATE TABLE IF NOT EXISTS friends (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        is_contact INTEGER NOT NULL DEFAULT 0
    )
    """)

    # 2. Add friend_id column to events if missing
    if not column_exists(cur, "events", "friend_id"):
        cur.execute("ALTER TABLE events ADD COLUMN friend_id TEXT")

    # 3. Fetch distinct friend names from legacy events
    cur.execute("""
    SELECT DISTINCT friend
    FROM events
    WHERE friend IS NOT NULL
    """)
    friend_names = [row[0] for row in cur.fetchall()]

    print(f"Found {len(friend_names)} unique friends")

    name_to_id = {}

    # 4. Insert friends
    for name in friend_names:
        cur.execute("SELECT id FROM friends WHERE name = ?", (name,))
        row = cur.fetchone()
        if row:
            friend_id = row[0]
        else:
            friend_id = str(uuid4())
            cur.execute("""
            INSERT INTO friends (id, name)
            VALUES (?, ?)
            """, (friend_id, name))
        name_to_id[name] = friend_id

    # 5. Backfill events.friend_id
    for name, fid in name_to_id.items():
        cur.execute("""
        UPDATE events
        SET friend_id = ?
        WHERE friend = ?
        """, (fid, name))

    conn.commit()
    conn.close()

    print("✓ Migration complete")


if __name__ == "__main__":
    migrate()
