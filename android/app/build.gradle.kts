plugins {
    id("com.android.application")
    id("kotlin-android")
}

android {
    val compileSdkVersion: Int by rootProject.extra
    compileSdk = compileSdkVersion

    namespace = "YOUR_PACKAGE_NAME" // Replace with your actual package name

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        val minSdkVersion: Int by rootProject.extra
        val targetSdkVersion: Int by rootProject.extra
        
        applicationId = "YOUR_PACKAGE_NAME" // Replace with your actual package name
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation(project(":flutter"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}