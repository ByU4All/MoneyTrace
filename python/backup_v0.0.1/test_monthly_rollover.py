# test_month_rollover.py
from datetime import date
from engine import compute_available_budget

BASE_BUDGET = 1_000_000  # ₹10,000

events = [
    {
        "type": "expense",
        "amount": 400_000,
        "event_date": date(2026, 1, 10),
    },
    {
        "type": "liability_created",
        "amount": 100_000,
        "event_date": date(2026, 1, 15),
    },
    {
        "type": "expense",
        "amount": 200_000,
        "event_date": date(2026, 2, 5),
    },
]

def events_for_budget_month(events, month, year):
    filtered = []
    for e in events:
        if e["type"] == "liability_created":
            filtered.append(e)
        elif e["event_date"].month == month and e["event_date"].year == year:
            filtered.append(e)
    return filtered


# January
jan_events = events_for_budget_month(events, 1, 2026)
jan_budget = compute_available_budget(BASE_BUDGET, jan_events)

# February
feb_events = events_for_budget_month(events, 2, 2026)
feb_budget = compute_available_budget(BASE_BUDGET, feb_events)

assert jan_budget == 500_000   # 10000 - 4000 - 1000
assert feb_budget == 700_000   # 10000 - 2000 - 1000

print("✓ Month rollover logic works correctly")
