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
//
// Using pluginManager.withPlugin (fires as soon as that plugin is applied,
// past or future) rather than afterEvaluate -- :app is evaluated early via
// evaluationDependsOn above, and calling afterEvaluate on a project that has
// already finished evaluating throws.
subprojects {
    // :app already configures itself consistently (Java 17 / Kotlin 17) in
    // its own build.gradle.kts, and -- being evaluated early via
    // evaluationDependsOn above -- has already had compileOptions finalized
    // by AGP by the time this block runs. Only the plugin subprojects (whose
    // bundled Gradle config is what's actually mismatched) need overriding.
    if (name == "app") return@subprojects

    pluginManager.withPlugin("com.android.application") {
        extensions.configure<com.android.build.gradle.BaseExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.gradle.BaseExtension> {
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

    // compileSdk (unlike compileOptions) is explicitly set by every plugin
    // module's own build.gradle -- since that runs *after* the
    // pluginManager.withPlugin callback above fires (right when the plugin
    // is applied, near the top of the module's script), setting it there
    // gets silently overwritten moments later by the module's own
    // `compileSdk = flutter.compileSdkVersion` (34) line. afterEvaluate runs
    // once the whole module script has finished, so it wins. Safe here --
    // only :app has the early-evaluation hazard, and it's already skipped
    // above.
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.compileSdkVersion(36)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
