import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Cargar y depurar propiedades de la clave
val keyProperties = Properties()
// Ruta corregida: Gradle busca desde el directorio raíz de Android
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    println("¡ÉXITO! Leyendo archivo key.properties...")
    keyProperties.load(keyPropertiesFile.inputStream())
    println("storeFile: " + keyProperties.getProperty("storeFile"))
    println("keyAlias: " + keyProperties.getProperty("keyAlias"))
} else {
    println("ERROR: El archivo key.properties sigue sin ser encontrado en la raíz de 'android'.")
}

android {
    namespace = "com.edaxedu.misfinanzas"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.edaxedu.misfinanzas"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
