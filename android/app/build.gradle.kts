plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nuvclip.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.nuvclip.app"
        // La escritura en MediaStore.Downloads (API 29+) es la unica via que se
        // usa para guardar los videos; el telefono destino corre Android 14, asi
        // que no hace falta la rama de almacenamiento heredado de versiones previas.
        minSdk = 29
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // yt-dlp trae binarios nativos de python por ABI; sin esto el APK
        // arranca pero no encuentra el interprete al invocarlo.
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // youtubedl-android usa Jackson para parsear el JSON de yt-dlp por
            // reflexion; R8 lo rompe ("class X is not a concrete class") aunque
            // la libreria trae sus propias reglas de ProGuard, porque no cubren
            // toda su cadena de dependencias. Sin ofuscacion no hay nada que
            // mantener vivo con reglas ad-hoc, y esta app no se publica en una
            // tienda donde el tamano/ofuscacion del APK importe.
            isMinifyEnabled = false
            isShrinkResources = false
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

dependencies {
    val youtubedlAndroidVer = "0.18.1"
    implementation("io.github.junkfood02.youtubedl-android:library:$youtubedlAndroidVer")
    // Necesario para descargas donde video y audio llegan como pistas
    // separadas (yt-dlp las fusiona invocando este binario); TikTok e
    // Instagram casi siempre sirven mp4 ya muxeado, pero sin esto esa
    // minoria de casos fallaria en vez de degradar a una calidad menor.
    implementation("io.github.junkfood02.youtubedl-android:ffmpeg:$youtubedlAndroidVer")

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    implementation("androidx.core:core-ktx:1.17.0")

    testImplementation("junit:junit:4.13.2")
}
