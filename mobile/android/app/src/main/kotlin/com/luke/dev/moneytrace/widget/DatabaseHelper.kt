package com.luke.dev.moneytrace.widget

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import java.io.File
import java.time.LocalDate
import java.util.UUID

data class AccountItem(val id: String, val name: String, val isDefault: Boolean)
data class CategoryItem(val id: String, val name: String)
data class BudgetInfo(
    val baseBudget: Int,
    val available: Int,
    val spent: Int,
    val unpaidCommitments: Int,
    val liabilities: Int,
    val receivables: Int,
)

class DatabaseHelper(private val context: Context) {

    private fun getDbPath(): String {
        // Flutter stores the DB in app_flutter/ directory, not files/
        val appFlutterDir = File(context.dataDir, "app_flutter")
        return File(appFlutterDir, "moneytrace.db").absolutePath
    }

    private fun openDb(): SQLiteDatabase {
        return SQLiteDatabase.openDatabase(
            getDbPath(),
            null,
            SQLiteDatabase.OPEN_READWRITE
        )
    }

    fun dbExists(): Boolean = File(getDbPath()).exists()

    private fun getSetting(db: SQLiteDatabase, key: String): String? {
        val cursor = db.rawQuery("SELECT value FROM settings WHERE key = ?", arrayOf(key))
        cursor.use {
            return if (it.moveToFirst()) it.getString(0) else null
        }
    }

    /**
     * Compute budget info matching the Flutter engine logic:
     * - Get base_budget and budget_reset_day from settings
     * - Determine budget period (year, month) based on reset day
     * - Query events for that period
     * - available = base + adjustments + settlements_received - expenses - liabilities - emi_payments
     * - spent = sum of expense + settlement_paid amounts in period
     */
    fun getBudgetInfo(): BudgetInfo {
        val db = openDb()
        try {
            val baseBudget = getSetting(db, "base_budget")?.toIntOrNull() ?: 1000000
            val resetDay = getSetting(db, "budget_reset_day")?.toIntOrNull() ?: 1

            val today = LocalDate.now()
            val (year, month) = if (today.dayOfMonth >= resetDay) {
                Pair(today.year, today.monthValue)
            } else {
                if (today.monthValue == 1) Pair(today.year - 1, 12)
                else Pair(today.year, today.monthValue - 1)
            }

            val periodStart = LocalDate.of(year, month, resetDay)
            val periodEnd = if (month == 12) LocalDate.of(year + 1, 1, resetDay)
                           else LocalDate.of(year, month + 1, resetDay)

            // Budget period events
            val cursor = db.rawQuery(
                "SELECT type, amount, recurring_id, description FROM events WHERE event_date >= ? AND event_date < ?",
                arrayOf(periodStart.toString(), periodEnd.toString())
            )

            var available = baseBudget
            var spent = 0
            val periodEventKeys = mutableSetOf<String>() // track recurring_id and description+type

            cursor.use {
                while (it.moveToNext()) {
                    val type = it.getString(0)
                    val amount = it.getInt(1)
                    val recurringId = it.getString(2)
                    val description = it.getString(3)
                    when (type) {
                        "expense" -> { available -= amount; spent += amount }
                        "liability" -> available -= amount
                        "settlement_received" -> available += amount
                        "budget_adjustment" -> available += amount
                        "emi_payment" -> { available -= amount; spent += amount }
                        "settlement_paid" -> spent += amount
                    }
                    if (recurringId != null) periodEventKeys.add(recurringId)
                    if (description != null) periodEventKeys.add("$description|$type")
                }
            }

            // Unpaid recurring commitments (same logic as dashboard_provider.dart)
            var unpaidCommitments = 0
            val recurringCursor = db.rawQuery(
                "SELECT id, type, amount, frequency, next_due_date, name FROM recurring_transactions WHERE is_active = 1",
                null
            )
            recurringCursor.use {
                while (it.moveToNext()) {
                    val recType = it.getString(1)
                    if (recType != "expense" && recType != "emi_payment") continue
                    val recAmount = it.getInt(2)
                    val frequency = it.getString(3)
                    val nextDueDate = it.getString(4)
                    val recId = it.getString(0)
                    val recName = it.getString(5)

                    val relevant = when (frequency) {
                        "monthly", "daily", "weekly" -> true
                        "bimonthly", "quarterly", "half_yearly", "yearly" -> {
                            if (nextDueDate != null) {
                                val ndd = LocalDate.parse(nextDueDate)
                                ndd.monthValue == month && ndd.year == year
                            } else false
                        }
                        else -> false
                    }

                    if (relevant) {
                        val alreadyPaid = periodEventKeys.contains(recId) ||
                            periodEventKeys.contains("$recName|$recType")
                        if (!alreadyPaid) {
                            unpaidCommitments += recAmount
                        }
                    }
                }
            }

            // Subtract unpaid commitments from available (matches dashboard_provider.dart:104)
            available -= unpaidCommitments

            // Liabilities and receivables from ALL events
            var liabilities = 0
            var receivables = 0
            val allCursor = db.rawQuery("SELECT type, amount FROM events", null)
            allCursor.use {
                while (it.moveToNext()) {
                    val type = it.getString(0)
                    val amount = it.getInt(1)
                    when (type) {
                        "liability" -> liabilities += amount
                        "settlement_paid" -> liabilities -= amount
                        "receivable" -> receivables += amount
                        "settlement_received" -> receivables -= amount
                    }
                }
            }
            if (liabilities < 0) liabilities = 0
            if (receivables < 0) receivables = 0

            return BudgetInfo(baseBudget, available, spent, unpaidCommitments, liabilities, receivables)
        } finally {
            db.close()
        }
    }

    fun getActiveAccounts(): List<AccountItem> {
        val accounts = mutableListOf<AccountItem>()
        val db = openDb()
        try {
            val cursor = db.rawQuery(
                "SELECT id, name, is_default FROM accounts WHERE is_active = 1 ORDER BY is_default DESC, name ASC",
                null
            )
            cursor.use {
                while (it.moveToNext()) {
                    accounts.add(
                        AccountItem(
                            id = it.getString(0),
                            name = it.getString(1),
                            isDefault = it.getInt(2) == 1
                        )
                    )
                }
            }
        } finally {
            db.close()
        }
        return accounts
    }

    fun getCategories(): List<CategoryItem> {
        val categories = mutableListOf<CategoryItem>()
        val db = openDb()
        try {
            val cursor = db.rawQuery(
                "SELECT id, name FROM categories ORDER BY name ASC",
                null
            )
            cursor.use {
                while (it.moveToNext()) {
                    categories.add(
                        CategoryItem(
                            id = it.getString(0),
                            name = it.getString(1)
                        )
                    )
                }
            }
        } finally {
            db.close()
        }
        return categories
    }

    fun getOrCreateCategory(name: String): String {
        val trimmed = name.trim()
        if (trimmed.isEmpty()) return ""

        val db = openDb()
        try {
            // Check if category already exists (case-insensitive)
            val cursor = db.rawQuery(
                "SELECT name FROM categories WHERE LOWER(name) = LOWER(?)",
                arrayOf(trimmed)
            )
            cursor.use {
                if (it.moveToFirst()) {
                    return it.getString(0) // Return existing name with original casing
                }
            }

            // Create new category
            val values = ContentValues().apply {
                put("id", UUID.randomUUID().toString())
                put("name", trimmed)
                put("is_default", 0)
            }
            db.insert("categories", null, values)
            return trimmed
        } finally {
            db.close()
        }
    }

    fun insertExpense(
        amountPaise: Int,
        category: String?,
        accountId: String?,
        description: String?
    ): Boolean {
        val db = openDb()
        try {
            db.beginTransaction()
            try {
                val today = LocalDate.now().toString() // YYYY-MM-DD

                val eventValues = ContentValues().apply {
                    put("id", UUID.randomUUID().toString())
                    put("type", "expense")
                    put("amount", amountPaise)
                    put("category", category)
                    put("description", description?.ifBlank { null })
                    put("account_id", accountId)
                    put("event_date", today)
                    put("created_at", today)
                }
                val result = db.insert("events", null, eventValues)
                if (result == -1L) return false

                // Update account tracked balance
                if (!accountId.isNullOrEmpty()) {
                    db.execSQL(
                        "UPDATE accounts SET tracked_balance = tracked_balance - ? WHERE id = ?",
                        arrayOf(amountPaise, accountId)
                    )
                }

                db.setTransactionSuccessful()
                return true
            } finally {
                db.endTransaction()
            }
        } finally {
            db.close()
        }
    }
}
