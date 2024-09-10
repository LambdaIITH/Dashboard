package dev.iith.dashboard

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class MessMenuWidget : AppWidgetProvider() {

    @SuppressLint("RemoteViewLayout")
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val jsonData = widgetData.getString("widget_mess_menu", null)


            val views = RemoteViews(context.packageName, R.layout.mess_menu_widget)

            if (jsonData != null) {
                val messMenu = try {
                    Gson().fromJson(jsonData, MessMenuModel::class.java)
                } catch (e: Exception) {
                    Log.e("MessMenuWidget", "Error parsing JSON: ${e.message}")
                    null
                }

                if (messMenu != null) {

                    val currentMealData = getCurrentMealData(messMenu)
                    val extras = getCurrentExtrasData(messMenu)

                    if (currentMealData != null) {
                        views.setTextViewText(R.id.textView3, currentMealData.first)

                        val temp = currentMealData.second
                        val res = StringBuilder()

                        // Loop through the list and append index + meal item
                        for (i in temp.indices) {
                            res.append("${i + 1}. ${temp[i]}, ")
                        }

                        res.append("\n\ncdExtras: ")

                        val ext = extras?.second
                        if (ext != null) {
                            for (i in ext.indices) {
                                res.append("${i + 1}. ${ext[i]}, ")
                            }
                        }

                        // Set the result to the TextView
                        views.setTextViewText(R.id.textView6, res.toString().trim()) // Using trim() to remove any trailing newlines
                    } else {
                        views.setTextViewText(R.id.textView3, "No meals available")
                        views.setTextViewText(R.id.textView6, "")
                    }
                } else {
                    views.setTextViewText(R.id.textView3, "Failed to load menu")
                    views.setTextViewText(R.id.textView6, "")
                }
            } else {
                views.setTextViewText(R.id.textView3, "No data available")
                views.setTextViewText(R.id.textView6, "")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun getCurrentMealData(messMenu: MessMenuModel): Pair<String, List<String>>? {
        val today = SimpleDateFormat("EEEE", Locale.getDefault()).format(Date())

        val meals = messMenu.LDH?.get(today)

        meals?.let {
            val calendar = Calendar.getInstance()
            val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
            val currentMinute = calendar.get(Calendar.MINUTE)

            return when {
                currentHour < 10 || (currentHour == 10 && currentMinute <= 30) -> {
                    "Breakfast" to (meals.Breakfast ?: emptyList())
                }

                currentHour < 14 || (currentHour == 14 && currentMinute <= 45) -> {
                    "Lunch" to (meals.Lunch ?: emptyList())
                }

                currentHour < 18 || (currentHour == 18 && currentMinute <= 0) -> {
                    "Snacks" to (meals.Snacks ?: emptyList())
                }

                currentHour < 21 || (currentHour == 21 && currentMinute <= 30) -> {
                    "Dinner" to (meals.Dinner ?: emptyList())
                }

                else -> null
            }
        }

        return null
    }

    private fun getCurrentExtrasData(messMenu: MessMenuModel): Pair<String, List<String>>? {
        val today = SimpleDateFormat("EEEE", Locale.getDefault()).format(Date())

        val additional = messMenu.LDHAdditional?.get(today)

        additional?.let {
            val calendar = Calendar.getInstance()
            val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
            val currentMinute = calendar.get(Calendar.MINUTE)

            return when {
                currentHour < 10 || (currentHour == 10 && currentMinute <= 30) -> {
                    "Breakfast" to (additional.Breakfast ?: emptyList())
                }

                currentHour < 14 || (currentHour == 14 && currentMinute <= 45) -> {
                    "Lunch" to ((additional.Lunch ?: emptyList()))
                }

                currentHour < 18 || (currentHour == 18 && currentMinute <= 0) -> {
                    "Snacks" to  (additional.Snacks ?: emptyList())
                }

                currentHour < 21 || (currentHour == 21 && currentMinute <= 30) -> {
                    "Dinner" to (additional.Dinner ?: emptyList())
                }

                else -> null
            }
        }

        return null
    }

    override fun onEnabled(context: Context) {}

    override fun onDisabled(context: Context) {}
}
