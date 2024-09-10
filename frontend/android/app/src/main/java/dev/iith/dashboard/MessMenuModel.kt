package dev.iith.dashboard

import com.google.gson.annotations.SerializedName

data class MessMenuModel(
    val LDH: Map<String, DayMenu>?,
    val UDH: Map<String, DayMenu>?,
    @SerializedName("LDH Additional") val LDHAdditional: Map<String, AdditionalMenu>?,
    @SerializedName("UDH Additional") val UDHAdditional: Map<String, AdditionalMenu>?
)

data class DayMenu(
    val Breakfast: List<String>?,
    val Lunch: List<String>?,
    val Snacks: List<String>?,
    val Dinner: List<String>?
)

data class AdditionalMenu(
    val Breakfast: List<String>?,
    val Lunch: List<String>?,
    val Snacks: List<String>?,
    val Dinner: List<String>?
)
