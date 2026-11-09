import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// la firma de release vive fuera del repositorio: android/key.properties (ignorado por git) o variables de entorno en CI
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
fun signing(name: String, env: String): String? = keystoreProperties.getProperty(name) ?: System.getenv(env)

android {
    namespace = "com.wasichai.lesen"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications programa recordatorios con java.time también en Android antiguos
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.wasichai.lesen"
        // Android 7.0: almacenamiento seguro con Keystore y TLS moderno
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val storeFile = signing("storeFile", "LESEN_ANDROID_KEYSTORE")
        if (storeFile != null) {
            create("release") {
                this.storeFile = file(storeFile)
                storePassword = signing("storePassword", "LESEN_ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signing("keyAlias", "LESEN_ANDROID_KEY_ALIAS")
                keyPassword = signing("keyPassword", "LESEN_ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildFeatures {
        resValues = true
    }

    // un identificador por entorno, para instalar dev, staging y prod a la vez
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Lesen Dev")
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Lesen Staging")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Lesen")
        }
    }

    buildTypes {
        release {
            // sin firma configurada, la release se firma con la clave de depuración: sirve para probar, no para publicar
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
