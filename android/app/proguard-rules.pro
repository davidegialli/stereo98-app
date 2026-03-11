# Fix: flutter_local_notifications "Missing type parameter" in release builds
# R8 stripa i generic type da Gson TypeToken — queste regole lo impediscono
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Gson adapters
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter local notifications — non toccare nulla del plugin
-keep class com.dexterous.** { *; }

# OpenTelemetry — classi mancanti segnalate da R8
-dontwarn io.opentelemetry.**
-keep class io.opentelemetry.** { *; }

# Jackson — usato da OpenTelemetry exporter
-dontwarn com.fasterxml.jackson.**
-keep class com.fasterxml.jackson.** { *; }

# AutoValue — usato da OpenTelemetry SDK
-dontwarn com.google.auto.value.**
