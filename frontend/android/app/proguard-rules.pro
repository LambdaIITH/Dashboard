# Preserve model classes and their fields
-keep class dev.iith.dashboard.MessMenuModel { *; }
-keep class dev.iith.dashboard.DayMenu { *; }
-keep class dev.iith.dashboard.AdditionalMenu { *; }

# Keep Gson annotations
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep annotation attributes
-keepattributes Signature
-keepattributes *Annotation*
