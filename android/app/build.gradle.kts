plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter 的 Gradle 插件必须放在 Android 和 Kotlin 插件之后应用。
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sickandflutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: 替换为项目正式使用的唯一应用标识。
        applicationId = "com.example.sickandflutter"
        // 以下版本与 SDK 配置可按实际发布要求调整。
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: 接入正式发布签名配置。
            // 当前先复用调试签名，保证 `flutter run --release` 可以跑通。
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
