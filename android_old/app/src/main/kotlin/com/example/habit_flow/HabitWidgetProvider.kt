package com.example.habit_flow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class HabitWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.habit_widget).apply {
                // Open App on Title Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // Progress text
                val progressText = widgetData.getString("progress_text", "0 of 0 done")
                setTextViewText(R.id.tv_progress, progressText)

                // Habits JSON
                val habitsJson = widgetData.getString("widget_habits_json", "[]")
                try {
                    val array = JSONArray(habitsJson)
                    
                    // Row 1
                    if (array.length() > 0) {
                        val item = array.getJSONObject(0)
                        setTextViewText(R.id.tv_habit_1_name, item.optString("name", ""))
                        val isDone = item.optBoolean("isDone", false)
                        setImageViewResource(
                            R.id.btn_check_1,
                            if (isDone) android.R.drawable.checkbox_on_background else android.R.drawable.checkbox_off_background
                        )
                        val id = item.optString("id", "")
                        val toggleIntent = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("habitflow://toggle_habit?id=$id")
                        )
                        setOnClickPendingIntent(R.id.btn_check_1, toggleIntent)
                    }

                    // Row 2
                    if (array.length() > 1) {
                        val item = array.getJSONObject(1)
                        setTextViewText(R.id.tv_habit_2_name, item.optString("name", ""))
                        val isDone = item.optBoolean("isDone", false)
                        setImageViewResource(
                            R.id.btn_check_2,
                            if (isDone) android.R.drawable.checkbox_on_background else android.R.drawable.checkbox_off_background
                        )
                        val id = item.optString("id", "")
                        val toggleIntent = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("habitflow://toggle_habit?id=$id")
                        )
                        setOnClickPendingIntent(R.id.btn_check_2, toggleIntent)
                    }

                    // Row 3
                    if (array.length() > 2) {
                        val item = array.getJSONObject(2)
                        setTextViewText(R.id.tv_habit_3_name, item.optString("name", ""))
                        val isDone = item.optBoolean("isDone", false)
                        setImageViewResource(
                            R.id.btn_check_3,
                            if (isDone) android.R.drawable.checkbox_on_background else android.R.drawable.checkbox_off_background
                        )
                        val id = item.optString("id", "")
                        val toggleIntent = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("habitflow://toggle_habit?id=$id")
                        )
                        setOnClickPendingIntent(R.id.btn_check_3, toggleIntent)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
