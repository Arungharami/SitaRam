plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// ─── Load signing credentials from key.properties (never commit this file) ───
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// A production release must never silently fall back to the Android debug key.
// CI preflight builds that need a non-production signature must create their own
// explicitly temporary key.properties/keystore before invoking a Release task.
val releaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (releaseTaskRequested && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Release signing credentials are missing. Configure android/key.properties " +
            "from the verified SitaRam upload keystore; debug-signing fallback is prohibited."
    )
}

android {
    namespace = "com.leadai.sitaram"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ─── Signing Configurations ───────────────────────────────────────────────
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.leadai.sitaram"

        // just_audio requires minSdk 21; target Android 16 for current Play policy.
        minSdk = 21
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Optimise APK size — keep only the most common ABIs
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    buildTypes {
        // ── Debug (unchanged) ────────────────────────────────────────────────
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }

        // ── Release (production) ─────────────────────────────────────────────
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }

            // Enable R8 shrinking & resource stripping
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
