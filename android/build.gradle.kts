allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Some plugin modules (e.g. flutter_timezone) bundle a Gradle config with a
// mismatched Java/Kotlin JVM target (javac 11 vs kotlinc 1.8), which fails
// under this project's AGP/Kotlin setup with "Inconsistent JVM Target
// Compatibility Between Java and Kotlin Tasks". Force every subproject to a
// single consistent target regardless of what it declares internally.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { androidExt ->
            (androidExt as? com.android.build.gradle.BaseExtension)?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
