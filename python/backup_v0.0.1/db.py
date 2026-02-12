def init_db(path="moneytrace.db"):
    conn = sqlite3.connect(path)

    conn.execute("""
    CREATE TABLE IF NOT EXISTS friends (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        is_contact INTEGER NOT NULL DEFAULT 0
    )
    """)

    conn.execute("""
    CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT,
        friend_id TEXT,
        description TEXT,
        event_date TEXT NOT NULL,
        FOREIGN KEY(friend_id) REFERENCES friends(id)
    )
    """)

    conn.commit()
    return conn


def get_or_create_friend(conn, name: str, phone: str | None = None):
    cur = conn.cursor()

    cur.execute(
        "SELECT id FROM friends WHERE name = ? AND (phone = ? OR phone IS NULL)",
        (name, phone),
    )
    row = cur.fetchone()

    if row:
        return row[0]

    friend_id = str(uuid4())
    cur.execute("""
    INSERT INTO friends (id, name, phone, is_contact)
    VALUES (?, ?, ?, ?)
    """, (friend_id, name, phone, int(bool(phone))))

    conn.commit()
    return friend_id
