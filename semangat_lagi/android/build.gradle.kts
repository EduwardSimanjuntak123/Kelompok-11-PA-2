import java.util.Properties
import java.io.FileInputStream

// Load local.properties file
val localProperties = Properties()
val localPropertiesFile = file("local.properties")

if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { localProperties.load(it) }
}

// Baca path Flutter SDK
val flutterSdkPath: String? = localProperties.getProperty("flutter.sdk")
requireNotNull(flutterSdkPath) { "flutter.sdk tidak ditemukan di local.properties. Pastikan Flutter terinstal dan jalankan 'flutter doctor'." }

// Atur direktori build agar lebih rapi
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


