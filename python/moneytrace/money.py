from dataclasses import dataclass
from moneytrace.currency import Currency, INR


@dataclass(frozen=True)
class Money:
    amount: int          # amount in minor units (paise)
    currency: Currency = INR   # instance of Currency class

    def __add__(self, other: "Money") -> "Money":
        self._assert_same_currency(other)
        return Money(amount=self.amount + other.amount, currency=self.currency)
    
    def __sub__(self, other: "Money") -> "Money":
        self._assert_same_currency(other)
        return Money(amount=self.amount - other.amount, currency=self.currency)
    
    def _assert_same_currency(self, other: "Money"):
        if self.currency.code != other.currency.code:
            raise ValueError("Currency mismatch in Money operations")
        