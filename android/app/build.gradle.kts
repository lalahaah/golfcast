import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.projectDir.parentFile.resolve("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nextidealab.golfcast"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        val keyAliasValue = keystoreProperties.getProperty("keyAlias")
        val keyPasswordValue = keystoreProperties.getProperty("keyPassword")
        val storeFileValue = keystoreProperties.getProperty("storeFile")
        val storePasswordValue = keystoreProperties.getProperty("storePassword")

        if (keyAliasValue != null && keyPasswordValue != null && storeFileValue != null && storePasswordValue != null) {
            val keystoreFile = rootProject.projectDir.parentFile.resolve(storeFileValue)
            if (keystoreFile.exists()) {
                create("release") {
                    keyAlias = keyAliasValue
                    keyPassword = keyPasswordValue
                    storeFile = keystoreFile
                    storePassword = storePasswordValue
                }
            } else {
                println("WARNING: Keystore file not found at: ${keystoreFile.absolutePath}")
            }
        } else {
            println("WARNING: key.properties is incomplete or missing. File path: ${keystorePropertiesFile.absolutePath}")
        }
    }

    defaultConfig {
        applicationId = "com.nextidealab.golfcast"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            val releaseSigningConfig = signingConfigs.findByName("release")
            if (releaseSigningConfig != null) {
                signingConfig = releaseSigningConfig
            }
            
            // ProGuard 설정 적용 (최종 출시를 위해 다시 활성화)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
