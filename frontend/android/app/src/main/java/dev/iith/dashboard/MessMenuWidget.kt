package dev.iith.dashboard

import androidx.annotation.Keep
import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class MessMenuWidget : AppWidgetProvider() {

    @SuppressLint("RemoteViewLayout")
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("MessMenuWidget", "onUpdate called with widget IDs: ${appWidgetIds.contentToString()}")

        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val jsonData = widgetData.getString("widget_mess_menu", null)

            Log.d("MessMenuWidget", "Widget data: $jsonData")

            val views = RemoteViews(context.packageName, R.layout.mess_menu_widget)

            if (jsonData != null) {
                val gson = Gson()
                val jsonObject = JSONObject(jsonData)

                // Define TypeTokens
                val dayMenuType = object : TypeToken<Map<String, DayMenu>>() {}.type
                val additionalMenuType = object : TypeToken<Map<String, AdditionalMenu>>() {}.type

                // Parse LDH and UDH
                val ldhMap: Map<String, DayMenu>? = try {
                    gson.fromJson(jsonObject.getJSONObject("LDH").toString(), dayMenuType)
                } catch (e: Exception) {
                    Log.e("MessMenuWidget", "Error parsing LDH: ${e.message}")
                    null
                }

                val udhMap: Map<String, DayMenu>? = try {
                    gson.fromJson(jsonObject.getJSONObject("UDH").toString(), dayMenuType)
                } catch (e: Exception) {
                    Log.e("MessMenuWidget", "Error parsing UDH: ${e.message}")
                    null
                }

                // Parse LDH Additional and UDH Additional
                val ldhAdditionalMap: Map<String, AdditionalMenu>? = try {
                    gson.fromJson(
                        jsonObject.getJSONObject("LDH Additional").toString(),
                        additionalMenuType
                    )
                } catch (e: Exception) {
                    Log.e("MessMenuWidget", "Error parsing LDH Additional: ${e.message}")
                    null
                }

                val udhAdditionalMap: Map<String, AdditionalMenu>? = try {
                    gson.fromJson(
                        jsonObject.getJSONObject("UDH Additional").toString(),
                        additionalMenuType
                    )
                } catch (e: Exception) {
                    Log.e("MessMenuWidget", "Error parsing UDH Additional: ${e.message}")
                    null
                }

                // Create MessMenuModel
                val messMenu = MessMenuModel(
                    LDH = ldhMap,
                    UDH = udhMap,
                    LDHAdditional = ldhAdditionalMap,
                    UDHAdditional = udhAdditionalMap
                )

                // Log parsed menu for debugging
                Log.d("MessMenuWidget", "Parsed MessMenuModel: $messMenu")

                if (messMenu != null) {
                    val currentMealData = getCurrentMealData(messMenu)
                    val extras = getCurrentExtrasData(messMenu)

                    Log.d("CurrentMeal", currentMealData.toString())
                    Log.d("extras", extras.toString())

                    if (currentMealData != null) {
                        Log.d(
                            "MessMenuWidget",
                            "Current meal: ${currentMealData.first}, Items: ${currentMealData.second}"
                        )

                        views.setTextViewText(R.id.textView3, currentMealData.first)

                        val temp = currentMealData.second
                        val res = StringBuilder()

                        // Loop through the list and append index + meal item
                        for (i in temp.indices) {
                            res.append("${i + 1}. ${temp[i]}, ")
                        }

                        res.append("\n\nExtras: ")

                        val ext = extras?.second
                        if (ext != null) {
                            for (i in ext.indices) {
                                res.append("${i + 1}. ${ext[i]}, ")
                            }
                        }

                        Log.d(
                            "MessMenuWidget",
                            "Final string for TextView: ${res.toString().trim()}"
                        )

                        // Set the result to the TextView
                        views.setTextViewText(
                            R.id.textView6,
                            res.toString().trim()
                        ) // Using trim() to remove any trailing newlines
                    } else {
                        Log.d("MessMenuWidget", "No current meal data available")
                        views.setTextViewText(R.id.textView6, "No meals available")
                        views.setTextViewText(R.id.textView3, "Mess Menu")
                    }
                } else {
                    Log.d("MessMenuWidget", "Failed to parse mess menu data")
                    views.setTextViewText(R.id.textView6, "No meals available")
                    views.setTextViewText(R.id.textView3, "Mess Menu")
                }
            } else {
                Log.d("MessMenuWidget", "No widget data found")
                views.setTextViewText(R.id.textView6, "No data available")
                views.setTextViewText(R.id.textView3, "Mess Menu")
            }

            Log.d("MessMenuWidget", "Updating widget with ID: $appWidgetId")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun getCurrentMealData(messMenu: MessMenuModel): Pair<String, List<String>>? {
        val today = SimpleDateFormat("EEEE", Locale.getDefault()).format(Date())
        Log.d("MessMenuWidget", "Today is $today")

        val meals = messMenu.LDH?.get(today)

        // Check if meals for today are available
        if (meals == null) {
            Log.e(
                "MessMenuWidget",
                "No meals available for today ($today). Meals data: ${messMenu.LDH}"
            )
            return null
        }

        val calendar = Calendar.getInstance()
        val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
        val currentMinute = calendar.get(Calendar.MINUTE)
        Log.d("MessMenuWidget", "Current time: $currentHour:$currentMinute")

        return when {
            currentHour < 10 || (currentHour == 10 && currentMinute <= 30) -> {
                Log.d("MessMenuWidget", "Fetching Breakfast data")
                "Breakfast" to (meals.Breakfast ?: emptyList())
            }
            currentHour < 14 || (currentHour == 14 && currentMinute <= 45) -> {
                Log.d("MessMenuWidget", "Fetching Lunch data")
                "Lunch" to (meals.Lunch ?: emptyList())
            }
            currentHour < 18 || (currentHour == 18 && currentMinute <= 0) -> {
                Log.d("MessMenuWidget", "Fetching Snacks data")
                "Snacks" to (meals.Snacks ?: emptyList())
            }
            currentHour < 21 || (currentHour == 21 && currentMinute <= 30) -> {
                Log.d("MessMenuWidget", "Fetching Dinner data")
                "Dinner" to (meals.Dinner ?: emptyList())
            }
            else -> {
                Log.d("MessMenuWidget", "No meals found for the current time")
                null
            }
        }
    }

    private fun getCurrentExtrasData(messMenu: MessMenuModel): Pair<String, List<String>>? {
        val today = SimpleDateFormat("EEEE", Locale.getDefault()).format(Date())
        Log.d("MessMenuWidget", "Today is $today")

        val additional = messMenu.LDHAdditional?.get(today)

        additional?.let {
            val calendar = Calendar.getInstance()
            val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
            val currentMinute = calendar.get(Calendar.MINUTE)
            Log.d("MessMenuWidget", "Current time for extras: $currentHour:$currentMinute")

            return when {
                currentHour < 10 || (currentHour == 10 && currentMinute <= 30) -> {
                    "Breakfast" to (additional.Breakfast ?: emptyList())
                }
                currentHour < 14 || (currentHour == 14 && currentMinute <= 45) -> {
                    "Lunch" to (additional.Lunch ?: emptyList())
                }
                currentHour < 18 || (currentHour == 18 && currentMinute <= 0) -> {
                    "Snacks" to (additional.Snacks ?: emptyList())
                }
                currentHour < 21 || (currentHour == 21 && currentMinute <= 30) -> {
                    "Dinner" to (additional.Dinner ?: emptyList())
                }
                else -> {
                    Log.d("MessMenuWidget", "No extras found for the current time")
                    null
                }
            }
        }

        Log.d("MessMenuWidget", "No extras available for today")
        return null
    }

    override fun onEnabled(context: Context) {
        Log.d("MessMenuWidget", "Widget enabled")
    }

    override fun onDisabled(context: Context) {
        Log.d("MessMenuWidget", "Widget disabled")
    }
}
