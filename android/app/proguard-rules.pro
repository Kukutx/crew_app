# Stripe SDK 混淆规则
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# react-native-stripe
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Kotlin Metadata
-keepclassmembers class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# AndroidX
-dontwarn androidx.**
