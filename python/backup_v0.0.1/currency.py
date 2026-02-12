from dataclasses import dataclass


@dataclass(frozen=True)
class Currency:
    code: str            # "INR", "USD"
    symbol: str          # "₹", "$"
    minor_unit: int      # 100 for paise/cents, 1 for JPY
    name: str            # "Indian Rupee"


INR = Currency(
    code="INR",
    symbol="₹",
    minor_unit=100,
    name="Indian Rupee",
)

USD = Currency(
    code="USD",
    symbol="$",
    minor_unit=100,
    name="United States Dollar",
)