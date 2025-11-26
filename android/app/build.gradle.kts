import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.acore.draze"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Java 17 required for Android 15
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // Java 17
    }

    defaultConfig {
        applicationId = "com.acore.draze"
        minSdk = 24  // Ya jo bhi aapka minimum ho (21-24 recommended)
        targetSdk = 35  // Android 15 ke liye zaroori
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "flutter_embedding_renderer", "skia")
        multiDexEnabled = true  // Agar large app hai to ye add karo
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true  // Resources bhi shrink karo
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),  // Optimized version
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            // Debug build ke liye
            isMinifyEnabled = false
        }
    }

    // Ye add karo agar packaging conflicts aaye
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Agar MultiDex enable kiya hai to ye add karo
    implementation("androidx.multidex:multidex:2.0.1")
}