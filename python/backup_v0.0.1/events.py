from enum import Enum

class EventType(str, Enum):
    EXPENSE = "expense"
    LIABILITY_CREATED = "liability_created"
    RECEIVABLE_CREATED = "receivable_created"
    PAYBACK_PAID = "payback_paid"
    PAYBACK_RECEIVED = "payback_received"
    BUDGET_ADJUSTMENT = "budget_adjustment"

    