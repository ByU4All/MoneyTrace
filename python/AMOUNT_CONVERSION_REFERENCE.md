# MoneyTrace - Amount Conversion Reference

## Currency Conversion System

MoneyTrace uses **type-safe integer storage** for all amounts to avoid floating-point arithmetic errors.

### Core Principle
- **Storage**: All amounts stored in **minor units** (paise, cents, etc.)
- **Display**: All amounts shown in **major units** (rupees, dollars, etc.)
- **Input**: Users enter in major units (rupees/dollars)
- **Processing**: Frontend converts to minor units before sending to API

## Conversion Formulas

### JavaScript (Frontend)
```javascript
// Major → Minor (for storage)
function toMinorUnits(majorUnits) {
    return Math.round(majorUnits * 100);
}

// Minor → Major (for display)
function toMajorUnits(minorUnits) {
    return minorUnits / 100;
}

// Format for display
function formatAmount(minorUnits, currency = '₹') {
    const major = toMajorUnits(minorUnits);
    return `${currency}${major.toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
}
```

### Python (Backend)
```python
# Similar utilities available in currency.py
from currency import INR, USD

# Minor unit factor
INR.minor_unit  # 100 (100 paise = 1 rupee)
USD.minor_unit  # 100 (100 cents = 1 dollar)

# Conversion
def to_minor_units(major: float) -> int:
    return int(round(major * 100))

def to_major_units(minor: int) -> float:
    return minor / 100
```

## Conversion Examples

### Indian Rupees (INR)

| User Input (₹) | Stored (paise) | Display (₹) |
|----------------|----------------|-------------|
| 0.01 | 1 | ₹0.01 |
| 0.50 | 50 | ₹0.50 |
| 1.00 | 100 | ₹1.00 |
| 10.00 | 1,000 | ₹10.00 |
| 50.75 | 5,075 | ₹50.75 |
| 123.45 | 12,345 | ₹123.45 |
| 999.99 | 99,999 | ₹999.99 |
| 1,000.00 | 100,000 | ₹1,000.00 |
| 10,000.50 | 1,000,050 | ₹10,000.50 |
| 1,00,000.00 | 10,000,000 | ₹1,00,000.00 |

### US Dollars (USD)

| User Input ($) | Stored (cents) | Display ($) |
|----------------|----------------|-------------|
| 0.01 | 1 | $0.01 |
| 1.00 | 100 | $1.00 |
| 50.75 | 5,075 | $50.75 |
| 123.45 | 12,345 | $123.45 |
| 1,000.00 | 100,000 | $1,000.00 |

## Why Integer Storage?

### ❌ Floating Point Problems
```javascript
// With floats
0.1 + 0.2 === 0.3  // FALSE! (it's 0.30000000000000004)
50.75 + 49.25 === 100  // FALSE! (precision errors)

// Money calculations with floats are DANGEROUS
let balance = 0.1;
balance = balance + 0.2;
console.log(balance);  // 0.30000000000000004 💥
```

### ✅ Integer Safety
```javascript
// With integers (paise)
10 + 20 === 30  // TRUE ✅
5075 + 4925 === 10000  // TRUE ✅

// Money calculations with integers are SAFE
let balance = 10;  // 10 paise
balance = balance + 20;  // 30 paise
console.log(balance);  // 30 ✅
```

## UI Examples

### Event Creation Form

**User Experience:**
1. User types: `50.75`
2. Helper text shows: `= 5,075 paise`
3. On submit: `5075` sent to API (integer)
4. In database: `5075` stored (integer)
5. On display: Shows `₹50.75` (formatted)

**Code Flow:**
```javascript
// 1. User input
const userInput = 50.75;  // rupees

// 2. Convert for storage
const paise = toMinorUnits(userInput);  // 5075

// 3. Send to API
await API.createEvent({
    amount: paise,  // 5075 (integer)
    // ... other fields
});

// 4. Display later
const displayAmount = formatAmount(paise);  // "₹50.75"
```

### Dashboard Display

**From API to UI:**
```javascript
// API returns (example response)
{
    "monthly_spend": 123450,  // paise
    "budget_remaining": 876550,  // paise
}

// Display on screen
Screens.formatAmount(123450)   // "₹1,234.50"
Screens.formatAmount(876550)   // "₹8,765.50"
```

## Testing Amount Conversion

### Test Cases
```python
def test_amount_conversion():
    # Input → Storage → Display
    assert to_minor_units(123.45) == 12345
    assert to_major_units(12345) == 123.45
    
    # Edge cases
    assert to_minor_units(0.01) == 1      # 1 paisa
    assert to_minor_units(0.99) == 99     # 99 paise
    assert to_minor_units(1.00) == 100    # 1 rupee
    assert to_minor_units(1000.50) == 100050  # Large amount
```

## API Contract

### Request (Event Creation)
```json
POST /api/events
{
  "event_type": "expense",
  "amount": 5075,           // ALWAYS in paise (integer)
  "category": "food",
  "note": "Lunch"
}
```

### Response
```json
{
  "id": "abc123",
  "event_type": "expense",
  "amount": 5075,           // ALWAYS in paise (integer)
  "category": "food",
  "note": "Lunch",
  "timestamp": "2026-01-06"
}
```

### Display Views
```json
GET /api/summary
{
  "monthly_spend": 123450,       // paise
  "budget_remaining": 876550,    // paise
  "outstanding_liabilities": 50000,  // paise
  "outstanding_receivables": 25000   // paise
}
```

**Frontend converts for display:**
- Monthly Spend: ₹1,234.50
- Budget Remaining: ₹8,765.50
- You Owe: ₹500.00
- You'll Receive: ₹250.00

## Best Practices

### ✅ DO
- Always store amounts as integers (minor units)
- Convert to major units ONLY for display
- Use utility functions for conversions
- Round when converting to integers: `Math.round(value * 100)`
- Format with locale for display: `toLocaleString()`

### ❌ DON'T
- Store amounts as floats/decimals
- Do arithmetic with floats for money
- Mix major/minor units in the same calculation
- Forget to convert before sending to API
- Hardcode conversion factors (use currency config)

## Multi-Currency Support

### Current Implementation
```javascript
const currencies = {
    INR: { symbol: '₹', minor_unit: 100 },   // 100 paise = 1 rupee
    USD: { symbol: '$', minor_unit: 100 },   // 100 cents = 1 dollar
    JPY: { symbol: '¥', minor_unit: 1 },     // No minor unit
};
```

### Using Different Currencies
```javascript
// INR
formatAmount(12345, '₹')  // "₹123.45"

// USD
formatAmount(12345, '$')  // "$123.45"

// JPY (no minor units)
formatAmount(12345, '¥')  // "¥12,345"
```

## Summary

| Aspect | Value |
|--------|-------|
| Storage Format | Integer (paise/cents) |
| Display Format | Decimal (rupees/dollars) |
| Input Format | Decimal (rupees/dollars) |
| Conversion Factor | 100 (for INR/USD) |
| Precision | Exact (no floating errors) |
| Safety | Type-safe integers |

**Golden Rule**: Money is ALWAYS stored as integers in the smallest unit. Period. 💰✨

