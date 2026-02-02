# Flutter Local Notifications ProGuard rules
# Preserve generic signatures for TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Gson classes and TypeToken
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * implements com.google.gson.reflect.TypeToken

# Keep flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Preserve generic type information
-keepattributes Signature,RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations
