# example run 
print("This is an example run script.")

# run_example.py
from datetime import date
from moneytrace.engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
    compute_friend_balances,
    compute_category_spend,
    validate_invariants,
)

# Helper: today
today = date(2026, 1, 5)

# Base monthly budget: ₹10,000
BASE_BUDGET = 1_000_000  # paise

events = [
    # -------------------------------
    # Case 1: You paid ₹4000 for 4
    # -------------------------------
    {
        "type": "expense",
        "amount": 400_000,
        "category": "Eating Out",
        "friend": None,
        "description": "Dinner paid by me",
        "event_date": today,
    },
    {
        "type": "receivable_created",
        "amount": 100_000,
        "category": "Eating Out",
        "friend": "Sugam",
        "description": None,
        "event_date": today,
    },
    {
        "type": "receivable_created",
        "amount": 100_000,
        "category": "Eating Out",
        "friend": "Shrey",
        "description": None,
        "event_date": today,
    },
    {
        "type": "receivable_created",
        "amount": 100_000,
        "category": "Eating Out",
        "friend": "Dheeraj",
        "description": None,
        "event_date": today,
    },

    # -------------------------------
    # Case 2: Someone else paid ₹4000, you owe ₹5000
    # -------------------------------
    {
        "type": "liability_created",
        "amount": 500_000,
        "category": "Eating Out",
        "friend": "Sugam",
        "description": "Dinner paid by Sugam",
        "event_date": today,
    },

    # -------------------------------
    # Case 3: Solo dinner ₹1000
    # -------------------------------
    {
        "type": "expense",
        "amount": 100_000,
        "category": "Eating Out",
        "friend": None,
        "description": "Solo dinner",
        "event_date": today,
    },

    # -------------------------------
    # Case 4: Payback received from Shrey ₹1000
    # -------------------------------
    {
        "type": "payback_received",
        "amount": 100_000,
        "category": None,
        "friend": "Shrey",
        "description": "Payback for dinner",
        "event_date": today,
    },

    # -------------------------------
    # Case 5: Payed to Sugam ₹2000
    # -------------------------------
    {
        "type": "payback_paid",
        "amount": 200_000,     
        "category": None,
        "friend": "Sugam",
        "description": "Payback for dinner",
        "event_date": today,
    },
]

# Safety check
validate_invariants(events)

# -------------------------------
# Run engine
# -------------------------------
available_budget = compute_available_budget(BASE_BUDGET, events)
monthly_spend = compute_monthly_spend(events, month=1, year=2026)
liabilities = compute_outstanding_liabilities(events)
receivables = compute_outstanding_receivables(events)
friend_balances = compute_friend_balances(events)
category_spend = compute_category_spend(events, month=1, year=2026)

# -------------------------------
# Pretty print (for sanity)
# -------------------------------
def fmt(paise: int) -> str:
    return f"₹{paise / 100:.2f}"

print("=== RESULTS ===")
print("Base budget        :", fmt(BASE_BUDGET))
print("Available budget   :", fmt(available_budget))
print("Monthly spend      :", fmt(monthly_spend))
print("Outstanding owed   :", fmt(liabilities))
print("Outstanding due    :", fmt(receivables))
print("")

print("Per-friend balance:")
for k, v in friend_balances.items():
    print(f"  {k}: {fmt(v)}")

print("")
print("Category spend:")
for k, v in category_spend.items():
    print(f"  {k}: {fmt(v)}")
