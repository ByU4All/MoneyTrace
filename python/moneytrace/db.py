import sqlite3
from uuid import uuid4
from datetime import date


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


# ---------------------------------------------------------------------------
# Event CRUD
# ---------------------------------------------------------------------------

def create_event(conn, event_data: dict) -> str:
    """Create a new event. Returns the event ID."""
    event_id = str(uuid4())
    cur = conn.cursor()

    cur.execute("""
    INSERT INTO events (id, type, amount, category, friend_id, description, event_date)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        event_id,
        event_data["type"],
        event_data["amount"],
        event_data.get("category"),
        event_data.get("friend_id"),
        event_data.get("description"),
        event_data["event_date"].isoformat() if isinstance(event_data["event_date"], date) else event_data["event_date"],
    ))

    conn.commit()
    return event_id


def get_all_events(conn) -> list[dict]:
    """Get all events from the database."""
    cur = conn.cursor()
    cur.execute("""
    SELECT id, type, amount, category, friend_id, description, event_date
    FROM events
    ORDER BY event_date DESC, id DESC
    """)

    rows = cur.fetchall()
    events = []
    for r in rows:
        events.append({
            "id": r[0],
            "type": r[1],
            "amount": r[2],
            "category": r[3],
            "friend_id": r[4],
            "description": r[5],
            "event_date": date.fromisoformat(r[6]),
        })

    return events


def get_events_for_engine(conn) -> list[dict]:
    """Get all events formatted for engine consumption."""
    cur = conn.cursor()
    cur.execute("""
    SELECT type, amount, category, friend_id, description, event_date
    FROM events
    ORDER BY event_date, id
    """)

    rows = cur.fetchall()
    events = []
    for r in rows:
        events.append({
            "type": r[0],
            "amount": r[1],
            "category": r[2],
            "friend": r[3],  # Engine expects "friend" not "friend_id"
            "description": r[4],
            "event_date": date.fromisoformat(r[5]),
        })

    return events


# ---------------------------------------------------------------------------
# Friend CRUD
# ---------------------------------------------------------------------------

def create_friend(conn, name: str, phone: str | None = None) -> str:
    """Create a new friend. Returns the friend ID."""
    friend_id = str(uuid4())
    cur = conn.cursor()

    cur.execute("""
    INSERT INTO friends (id, name, phone, is_contact)
    VALUES (?, ?, ?, ?)
    """, (friend_id, name, phone, int(bool(phone))))

    conn.commit()
    return friend_id


def get_all_friends(conn) -> list[dict]:
    """Get all friends from the database."""
    cur = conn.cursor()
    cur.execute("""
    SELECT id, name, phone, is_contact
    FROM friends
    ORDER BY name
    """)

    rows = cur.fetchall()
    friends = []
    for r in rows:
        friends.append({
            "id": r[0],
            "name": r[1],
            "phone": r[2],
            "is_contact": bool(r[3]),
        })

    return friends


def get_friend_by_id(conn, friend_id: str) -> dict | None:
    """Get a friend by ID."""
    cur = conn.cursor()
    cur.execute("""
    SELECT id, name, phone, is_contact
    FROM friends
    WHERE id = ?
    """, (friend_id,))

    row = cur.fetchone()
    if not row:
        return None

    return {
        "id": row[0],
        "name": row[1],
        "phone": row[2],
        "is_contact": bool(row[3]),
    }


def get_events_by_friend(conn, friend_id: str) -> list[dict]:
    """Get all events for a specific friend."""
    cur = conn.cursor()
    cur.execute("""
    SELECT id, type, amount, category, friend_id, description, event_date
    FROM events
    WHERE friend_id = ?
    ORDER BY event_date DESC, id DESC
    """, (friend_id,))

    rows = cur.fetchall()
    events = []
    for r in rows:
        events.append({
            "id": r[0],
            "type": r[1],
            "amount": r[2],
            "category": r[3],
            "friend_id": r[4],
            "description": r[5],
            "event_date": date.fromisoformat(r[6]),
        })

    return events
