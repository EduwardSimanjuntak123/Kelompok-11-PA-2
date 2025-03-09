plugins {
    id("com.android.application") version "8.1.2"
    id("kotlin-android")
}
android {
    namespace = "com.example.semangat_lagi"
    compileSdk = 33 // Pastikan versi compileSdk sesuai dengan Flutter

    defaultConfig {
        applicationId = "com.example.semangat_lagi"
        minSdk = 21 // Sesuaikan dengan kebutuhan aplikasi
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
