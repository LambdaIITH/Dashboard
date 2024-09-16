package dev.iith.dashboard

import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class MessMenuModel(
    @SerializedName("LDH")
    @Keep val LDH: Map<String, DayMenu>?,
    @SerializedName("UDH")
    @Keep val UDH: Map<String, DayMenu>?,
    @SerializedName("LDH Additional")
    @Keep val LDHAdditional: Map<String, AdditionalMenu>?,
    @SerializedName("UDH Additional")
    @Keep val UDHAdditional: Map<String, AdditionalMenu>?
)

@Keep
data class DayMenu(
    @SerializedName("Breakfast")
    @Keep val Breakfast: List<String>?,
    @SerializedName("Lunch")
    @Keep val Lunch: List<String>?,
    @SerializedName("Snacks")
    @Keep val Snacks: List<String>?,
    @SerializedName("Dinner")
    @Keep val Dinner: List<String>?
)

@Keep
data class AdditionalMenu(
    @SerializedName("Breakfast")
    @Keep val Breakfast: List<String>?,
    @SerializedName("Lunch")
    @Keep val Lunch: List<String>?,
    @SerializedName("Snacks")
    @Keep val Snacks: List<String>?,
    @SerializedName("Dinner")
    @Keep val Dinner: List<String>?
)
