plugins {
    // Apply the Flutter plugin to the application build
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_quiz_app" // Replace with your actual package name
    compileSdk = 34 // Use a modern SDK version (e.g., 34 or 35)

    defaultConfig {
        applicationId = "com.example.flutter_quiz_app" // Replace with your actual package name
        minSdk = 21 // Keep minimum SDK version consistent
        targetSdk = 34
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
    // This library provides the desugared Java 8+ APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
// --- FIX END ---

flutter {
    // FIX: Removed 'file(...)' as the Kotlin DSL expects a String path for 'source'
    source = "../.."
}
