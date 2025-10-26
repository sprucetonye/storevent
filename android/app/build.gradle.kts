plugins {
    // Apply the Flutter plugin to the application build
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_quiz_app" // Replace with your actual package name
    // FIX 1: Increased compileSdk to 36 to satisfy plugin requirements (e.g., image_picker_android, path_provider_android).
    compileSdk = 36 

    defaultConfig {
        applicationId = "com.example.flutter_quiz_app" // Replace with your actual package name
        minSdk = 21 // Keep minimum SDK version consistent
        targetSdk = 34 // targetSdk can often remain lower than compileSdk
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    // --- FIX START: Correct setup for Java 17 and Desugaring ---
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Set to Java 17
        targetCompatibility = JavaVersion.VERSION_17 // Set to Java 17
        
        // This is where desugaring is enabled within the compileOptions block
        isCoreLibraryDesugaringEnabled = true 
    }
    // --- FIX END ---
    
    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }
}

// --- FIX START: Add the desugaring dependency ---
dependencies {
    // FIX 2: Updated desugar_jdk_libs version to 2.1.4 to satisfy flutter_local_notifications dependency.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
// --- FIX END ---

flutter {
    // FIX: Removed 'file(...)' as the Kotlin DSL expects a String path for 'source'
    source = "../.."
}
