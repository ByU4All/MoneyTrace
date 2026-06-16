package com.luke.dev.moneytrace.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import android.widget.Button
import android.widget.EditText
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import com.luke.dev.moneytrace.R
import kotlin.math.roundToInt

class QuickExpenseActivity : Activity() {

    private lateinit var dbHelper: DatabaseHelper
    private var accounts: List<AccountItem> = emptyList()
    private var categories: List<CategoryItem> = emptyList()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_quick_expense)

        dbHelper = DatabaseHelper(this)

        try {
            accounts = dbHelper.getActiveAccounts()
            categories = dbHelper.getCategories()
        } catch (e: Exception) {
            Toast.makeText(this, "Could not load data. Open the app first.", Toast.LENGTH_LONG).show()
            finish()
            return
        }

        setupAccountSpinner()
        setupCategoryAutoComplete()
        setupButtons()

        // Focus amount field
        findViewById<EditText>(R.id.edit_amount).requestFocus()
    }

    private fun setupAccountSpinner() {
        val spinner = findViewById<Spinner>(R.id.spinner_account)
        val accountNames = accounts.map { it.name }

        val adapter = object : ArrayAdapter<String>(
            this,
            android.R.layout.simple_spinner_item,
            accountNames
        ) {
            override fun getView(position: Int, convertView: View?, parent: android.view.ViewGroup): View {
                val view = super.getView(position, convertView, parent) as TextView
                view.setTextColor(getColor(R.color.widget_text_primary))
                view.textSize = 16f
                return view
            }

            override fun getDropDownView(position: Int, convertView: View?, parent: android.view.ViewGroup): View {
                val view = super.getDropDownView(position, convertView, parent) as TextView
                view.setTextColor(getColor(R.color.widget_text_primary))
                view.setBackgroundColor(getColor(R.color.widget_surface_light))
                view.setPadding(24, 24, 24, 24)
                view.textSize = 16f
                return view
            }
        }
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinner.adapter = adapter

        // Pre-select default account
        val defaultIndex = accounts.indexOfFirst { it.isDefault }
        if (defaultIndex >= 0) {
            spinner.setSelection(defaultIndex)
        }
    }

    private fun setupCategoryAutoComplete() {
        val autoComplete = findViewById<AutoCompleteTextView>(R.id.edit_category)
        val categoryNames = categories.map { it.name }

        val adapter = ArrayAdapter(
            this,
            android.R.layout.simple_dropdown_item_1line,
            categoryNames
        )
        autoComplete.setAdapter(adapter)
    }

    private fun setupButtons() {
        findViewById<Button>(R.id.btn_cancel).setOnClickListener {
            finish()
        }

        findViewById<Button>(R.id.btn_save).setOnClickListener {
            saveExpense()
        }
    }

    private fun saveExpense() {
        val amountText = findViewById<EditText>(R.id.edit_amount).text.toString().trim()
        val categoryText = findViewById<AutoCompleteTextView>(R.id.edit_category).text.toString().trim()
        val descriptionText = findViewById<EditText>(R.id.edit_description).text.toString().trim()
        val spinner = findViewById<Spinner>(R.id.spinner_account)

        // Validate amount
        val amountRupees = amountText.toDoubleOrNull()
        if (amountRupees == null || amountRupees <= 0) {
            Toast.makeText(this, "Enter a valid amount", Toast.LENGTH_SHORT).show()
            return
        }

        val amountPaise = (amountRupees * 100).roundToInt()

        // Get selected account
        val selectedAccountIndex = spinner.selectedItemPosition
        val accountId = if (selectedAccountIndex >= 0 && selectedAccountIndex < accounts.size) {
            accounts[selectedAccountIndex].id
        } else {
            null
        }

        // Handle category — create if new
        val category = if (categoryText.isNotEmpty()) {
            try {
                dbHelper.getOrCreateCategory(categoryText)
            } catch (e: Exception) {
                categoryText // Fall back to raw text if DB fails
            }
        } else {
            null
        }

        val description = descriptionText.ifEmpty { null }

        // Insert expense
        try {
            val success = dbHelper.insertExpense(amountPaise, category, accountId, description)
            if (success) {
                // Refresh all widget instances with updated budget
                refreshWidgets()
                Toast.makeText(this, "Expense added", Toast.LENGTH_SHORT).show()
                finish()
            } else {
                Toast.makeText(this, "Failed to save", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Toast.makeText(this, "Error: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    private fun refreshWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val widgetComponent = ComponentName(this, QuickExpenseWidget::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)
        for (id in widgetIds) {
            QuickExpenseWidget.updateWidget(this, appWidgetManager, id)
        }
    }
}
