# ui.py
import tkinter as tk
from datetime import date
from db import init_db
from engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
)

DB_PATH = "moneytrace.db"
BASE_BUDGET = 1_000_000  # ₹10,000 paise


def fmt(paise: int) -> str:
    return f"₹{paise / 100:.2f}"


class App:
    def __init__(self, root):
        self.root = root
        root.title("MoneyTrace — Test UI")

        self.conn = init_db(DB_PATH)

        # -------- Add Event --------
        tk.Label(root, text="Add Event").grid(row=0, column=0, sticky="w")

        self.type_var = tk.StringVar(value="expense")
        tk.Entry(root, textvariable=self.type_var).grid(row=1, column=0)

        self.amount_var = tk.StringVar()
        tk.Entry(root, textvariable=self.amount_var).grid(row=1, column=1)

        self.category_var = tk.StringVar()
        tk.Entry(root, textvariable=self.category_var).grid(row=1, column=2)

        self.friend_var = tk.StringVar()
        tk.Entry(root, textvariable=self.friend_var).grid(row=1, column=3)

        self.desc_var = tk.StringVar()
        tk.Entry(root, textvariable=self.desc_var).grid(row=1, column=4)

        tk.Button(root, text="Add", command=self.add_event).grid(row=1, column=5)

        # -------- Summary --------
        tk.Label(root, text="Summary").grid(row=3, column=0, sticky="w")

        self.month_var = tk.StringVar(value=str(date.today().month))
        self.year_var = tk.StringVar(value=str(date.today().year))

        tk.Entry(root, textvariable=self.month_var, width=5).grid(row=4, column=0)
        tk.Entry(root, textvariable=self.year_var, width=7).grid(row=4, column=1)

        tk.Button(root, text="Refresh", command=self.refresh).grid(row=4, column=2)

        self.output = tk.Text(root, height=10, width=70)
        self.output.grid(row=5, column=0, columnspan=6)

        self.refresh()

    def add_event(self):
        cur = self.conn.cursor()
        cur.execute("""
        INSERT INTO events (type, amount, category, friend, description, event_date)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (
            self.type_var.get(),
            int(self.amount_var.get()),
            self.category_var.get() or None,
            self.friend_var.get() or None,
            self.desc_var.get() or None,
            date.today().isoformat(),
        ))
        self.conn.commit()
        self.refresh()

    def refresh(self):
        cur = self.conn.cursor()
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

        m = int(self.month_var.get())
        y = int(self.year_var.get())

        budget = compute_available_budget(BASE_BUDGET, events)
        spend = compute_monthly_spend(events, m, y)
        owed = compute_outstanding_liabilities(events)
        due = compute_outstanding_receivables(events)

        self.output.delete("1.0", tk.END)
        self.output.insert(tk.END, f"Month spend   : {fmt(spend)}\n")
        self.output.insert(tk.END, f"Budget left   : {fmt(budget)}\n")
        self.output.insert(tk.END, f"You owe       : {fmt(owed)}\n")
        self.output.insert(tk.END, f"You will get  : {fmt(due)}\n")


if __name__ == "__main__":
    root = tk.Tk()
    App(root)
    root.mainloop()
