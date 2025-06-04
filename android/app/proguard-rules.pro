# Keep Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter plugins
-keep class io.flutter.plugin.** { *; }

# Multidex support
-keep class androidx.multidex.** { *; }

-dontwarn java.util.**
-keep class java.util.** { *; }
-keep class java.util.concurrent.** { *; }

-dontwarn j$.**
-keep class j$.** { *; }
