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
                keyAlias     = keystoreProperties["keyAlias"]     as String
                keyPassword  = keystoreProperties["keyPassword"]  as String
                storeFile    = file(keystoreProperties["storeFile"] as String)
                storePassword= keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.leadai.sitaram"

        // just_audio requires minSdk 21; target latest stable API
        minSdk    = 21
        targetSdk = 35

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
            versionNameSuffix   = "-debug"
        }

        // ── Release (production) ─────────────────────────────────────────────
        release {
            signingConfig = if (keystorePropertiesFile.exists())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug") // fallback for CI without key

            // Enable R8 shrinking & resource stripping
            isMinifyEnabled   = true
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
