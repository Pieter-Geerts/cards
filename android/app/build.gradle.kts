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
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
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

    defaultConfig {
        // Change from example domain to your unique application ID
        applicationId = "com.pietergeerts.cards"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Flutter 3.47 and integration_test require Android API 24 or later.
        minSdk = flutter.minSdkVersion
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

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
