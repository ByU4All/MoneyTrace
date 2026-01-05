# cli.py
import argparse
from datetime import date
from db import init_db
from engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
)

DB_PATH = "moneytrace.db"
BASE_BUDGET = 1_000_000  # ₹10,000 in paise


def add_event(args):
    conn = init_db(DB_PATH)
    cur = conn.cursor()

    cur.execute("""
    INSERT INTO events (type, amount, category, friend, description, event_date)
    VALUES (?, ?, ?, ?, ?, ?)
    """, (
        args.type,
        args.amount,
        args.category,
        args.friend,
        args.description,
        args.date or date.today().isoformat(),
    ))

    conn.commit()
    print("✓ Event added")


def summary(args):
    conn = init_db(DB_PATH)
    cur = conn.cursor()

    cur.execute("SELECT type, amount, category, friend, description, event_date FROM events")
    rows = cur.fetchall()

    events = [
        {
            "type": r[0],
            "amount": r[1],
            "category": r[2],
            "friend": r[3],
            "description": r[4],
            "event_date": date.fromisoformat(r[5]),
        }
        for r in rows
    ]

    budget = compute_available_budget(BASE_BUDGET, events)
    spend = compute_monthly_spend(events, args.month, args.year)
    owed = compute_outstanding_liabilities(events)
    due = compute_outstanding_receivables(events)

    def fmt(x): return f"₹{x / 100:.2f}"

    print("=== SUMMARY ===")
    print("Month spend     :", fmt(spend))
    print("Budget left     :", fmt(budget))
    print("You owe         :", fmt(owed))
    print("You will get    :", fmt(due))


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)

    add = sub.add_parser("add", help="Add a financial event")
    add.add_argument("--type", required=True)
    add.add_argument("--amount", type=int, required=True)
    add.add_argument("--category")
    add.add_argument("--friend")
    add.add_argument("--description")
    add.add_argument("--date")
    add.set_defaults(func=add_event)

    s = sub.add_parser("summary", help="Show monthly summary")
    s.add_argument("--month", type=int, required=True)
    s.add_argument("--year", type=int, required=True)
    s.set_defaults(func=summary)

    args = p.parse_args()

    # Safety guard (never hurts)
    if not hasattr(args, "func"):
        p.print_help()
        return

    args.func(args)


if __name__ == "__main__":
    main()
