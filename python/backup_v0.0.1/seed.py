from datetime import datetime, date
from moneytrace.db import init_db
from events import EventType


conn = init_db()
cur = conn.cursor()

today = date.today().isoformat()

events = [
    # Case 1: you paid 4000, split 4
    ("expense", 4000, "Eating Out", None, "Dinner paid by me", today),
    ("receivable_created", 1000, "Eating Out", "A", None, today),
    ("receivable_created", 1000, "Eating Out", "B", None, today),
    ("receivable_created", 1000, "Eating Out", "C", None, today),

    # Case 2: someone else paid, you owe 1000
    ("liability_created", 1000, "Eating Out", "D", None, today),

    # Case 3: solo dinner
    ("expense", 1000, "Eating Out", None, "Solo dinner", today),
]

cur.executemany("""
INSERT INTO events (type, amount, category, friend, description, event_date)
VALUES (?, ?, ?, ?, ?, ?)
""", events)

conn.commit()