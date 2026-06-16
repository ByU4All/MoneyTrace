package com.luke.dev.moneytrace.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import com.luke.dev.moneytrace.MainActivity
import com.luke.dev.moneytrace.R
import java.text.NumberFormat
import java.util.Locale

class QuickExpenseWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private fun formatPaise(paise: Int): String {
            val rupees = paise / 100.0
            val fmt = NumberFormat.getCurrencyInstance(Locale("en", "IN"))
            fmt.maximumFractionDigits = 0
            return fmt.format(rupees)
        }

        private fun makeAppIntent(context: Context, action: String, requestCode: Int): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("widget_action", action)
            }
            return PendingIntent.getActivity(
                context, requestCode, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // "+" button → QuickExpenseActivity
            val addIntent = Intent(context, QuickExpenseActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            val addPendingIntent = PendingIntent.getActivity(
                context, appWidgetId, addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Each stat area → open app with specific action
            val base = appWidgetId * 10
            val openAppIntent = makeAppIntent(context, "dashboard", base)
            val spentIntent = makeAppIntent(context, "visual_summary", base + 1)
            val reservedIntent = makeAppIntent(context, "reserved", base + 2)
            val liabilitiesIntent = makeAppIntent(context, "liabilities", base + 3)
            val receivablesIntent = makeAppIntent(context, "receivables", base + 4)

            val views = RemoteViews(context.packageName, R.layout.widget_quick_expense).apply {
                // General widget tap → open app dashboard
                setOnClickPendingIntent(R.id.widget_root, openAppIntent)
                // "+" button → quick expense dialog
                setOnClickPendingIntent(R.id.btn_add, addPendingIntent)
                // Stats → specific screens
                setOnClickPendingIntent(R.id.spent_section, spentIntent)
                setOnClickPendingIntent(R.id.reserved_section, reservedIntent)
                setOnClickPendingIntent(R.id.liabilities_section, liabilitiesIntent)
                setOnClickPendingIntent(R.id.receivables_section, receivablesIntent)
            }

            try {
                val dbHelper = DatabaseHelper(context)
                if (dbHelper.dbExists()) {
                    val b = dbHelper.getBudgetInfo()

                    views.setTextViewText(R.id.text_available, formatPaise(b.available))
                    views.setTextColor(R.id.text_available,
                        if (b.available >= 0) context.getColor(R.color.widget_success)
                        else context.getColor(R.color.widget_accent)
                    )

                    views.setTextViewText(R.id.text_subtitle, "of ${formatPaise(b.baseBudget)} remaining")

                    val usedPercent = if (b.baseBudget > 0) {
                        ((b.baseBudget - b.available).coerceAtLeast(0) * 100 / b.baseBudget).coerceIn(0, 100)
                    } else 0
                    views.setProgressBar(R.id.progress_budget, 100, usedPercent, false)

                    views.setTextViewText(R.id.text_spent, formatPaise(b.spent))
                    views.setTextViewText(R.id.text_reserved, formatPaise(b.unpaidCommitments))
                    views.setTextViewText(R.id.text_liabilities, formatPaise(b.liabilities))
                    views.setTextViewText(R.id.text_receivables, formatPaise(b.receivables))

                    views.setViewVisibility(R.id.reserved_section,
                        if (b.unpaidCommitments > 0) View.VISIBLE else View.GONE
                    )
                } else {
                    views.setTextViewText(R.id.text_available, "Open app first")
                    views.setTextColor(R.id.text_available, context.getColor(R.color.widget_text_secondary))
                    views.setTextViewText(R.id.text_subtitle, "")
                    views.setViewVisibility(R.id.stats_row, View.GONE)
                }
            } catch (e: Exception) {
                views.setTextViewText(R.id.text_available, "---")
                views.setTextViewText(R.id.text_subtitle, "")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
