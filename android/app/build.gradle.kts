import java.io.FileInputStream
import java.util.Properties

// Add at the top, before plugins section
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.pietergeerts.cards"  // Updated to match applicationId
    // mobile_scanner and some camera libraries require a newer Android SDK.
    // Use a concrete value here to ensure the app is compiled against the required SDK.
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(21))
        }
    }

    defaultConfig {
        // Change from example domain to your unique application ID
        applicationId = "com.pietergeerts.cards"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
    // androidx.camera:camera-core requires minSdk 23 or higher.
    // Set a concrete minSdk to avoid manifest merger failures from camera libraries.
    minSdk = 23
    // Target the same SDK as compile to avoid compatibility warnings from plugins.
    targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val hasAllProps =
                keystoreProperties["keyAlias"] != null &&
                keystoreProperties["keyPassword"] != null &&
                keystoreProperties["storeFile"] != null &&
                keystoreProperties["storePassword"] != null
            if (hasAllProps) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Only set signingConfig if all properties are present
            val hasAllProps =
                keystoreProperties["keyAlias"] != null &&
                keystoreProperties["keyPassword"] != null &&
                keystoreProperties["storeFile"] != null &&
                keystoreProperties["storePassword"] != null
            if (hasAllProps) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
