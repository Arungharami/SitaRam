# ─── SitaRam ProGuard / R8 Rules ─────────────────────────────────────────────

# ── Flutter Engine ────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }
-dontwarn io.flutter.**

# ── just_audio ────────────────────────────────────────────────────────────────
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# ── shared_preferences ────────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ── http / Dart HTTP client ────────────────────────────────────────────────────
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# ── Google Fonts (loaded from network, no code to keep) ───────────────────────
# No special rules needed — fonts are fetched at runtime.

# ── Kotlin coroutines ─────────────────────────────────────────────────────────
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ── Keep all enums (Dart interop may use them) ────────────────────────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ── Keep native method names ──────────────────────────────────────────────────
-keepclasseswithmembernames class * {
    native <methods>;
}

# ── General Android safe-keeps ────────────────────────────────────────────────
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
