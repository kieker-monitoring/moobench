plugins {
    kotlin("multiplatform") version "2.3.0"
    id("io.github.neonmika.k-perf-plugin") version "0.2.0" // dependency on the k-perf-plugin plugin
}


group = "io.github.neonmika"
version = "0.2.0"

repositories {
    mavenCentral()
}

val kperfEnabled = providers.gradleProperty("kperfEnabled")
    .map { it.toBoolean() }
    .also { if(it.isPresent) println("kperfEnabled specified, set to ${it.get()}") else println("kperfEnabled not specified, set to default true") }
    .getOrElse(true)

val kperfFlushEarly = providers.gradleProperty("kperfFlushEarly")
    .map { it.toBoolean() }
    .also { if(it.isPresent) println("kperfFlushEarly specified, set to ${it.get()}") else println("kperfFlushEarly not specified, set to default false") }
    .getOrElse(false)

val kperfInstrumentPropertyAccessors = providers.gradleProperty("kperfInstrumentPropertyAccessors")
    .map { it.toBoolean() }
    .also { if(it.isPresent) println("kperfInstrumentPropertyAccessors specified, set to ${it.get()}") else println("kperfInstrumentPropertyAccessors not specified, set to default false") }
    .getOrElse(false)

val kperfTestKIR = providers.gradleProperty("kperfTestKIR")
    .map { it.toBoolean() }
    .also { if(it.isPresent) println("kperfTestKIR specified, set to ${it.get()}") else println("kperfTestKIR not specified, set to default false") }
    .getOrElse(false)

val kperfMethods = providers.gradleProperty("kperfMethods")
    .also { if(it.isPresent) println("kperfMethods specified, set to ${it.get()}") else println("kperfMethods not specified, set to default .*") }
    .getOrElse(".*")


kperf {
    enabled = kperfEnabled
    flushEarly = kperfFlushEarly
    instrumentPropertyAccessors = kperfInstrumentPropertyAccessors
    testKIR = kperfTestKIR
    methods = kperfMethods
}

val hostOs = System.getProperty("os.name").lowercase()
val hostArch = System.getProperty("os.arch").lowercase()

kotlin {
    jvm {
        mainRun {
            mainClass.set("benchmark.MainKt")
        }

        compilations.all {
            compileTaskProvider.configure {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
                }
            }
        }
    }

    js(IR) {
        nodejs()
        binaries.executable()

        outputModuleName = if (kperfEnabled) {
            "kotlin-instrumented"
        } else {
            "kotlin-plain"
        }
    }

    when {
        hostOs.contains("linux") -> {
            linuxX64 {
                binaries.executable {
                    entryPoint = "benchmark.main"
                    baseName =
                        if (kperfEnabled) "kotlin-instrumented"
                        else "kotlin-plain"
                }
            }
        }

        hostOs.contains("windows") -> {
            mingwX64 {
                binaries.executable {
                    entryPoint = "benchmark.main"
                    baseName =
                        if (kperfEnabled) "kotlin-instrumented"
                        else "kotlin-plain"
                }
            }
        }

        hostOs.contains("mac") && hostArch in setOf("aarch64", "arm64") -> {
            macosArm64 {
                binaries.executable {
                    entryPoint = "benchmark.main"
                    baseName =
                        if (kperfEnabled) "kotlin-instrumented"
                        else "kotlin-plain"
                }
            }
        }

        hostOs.contains("mac") -> {
            macosX64 {
                binaries.executable {
                    entryPoint = "benchmark.main"
                    baseName =
                        if (kperfEnabled) "kotlin-instrumented"
                        else "kotlin-plain"
                }
            }
        }

        else -> {
            error("Unsupported operating system: $hostOs ($hostArch)")
        }
    }

    sourceSets {
        commonMain {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-cli:0.3.6")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
                implementation("org.jetbrains.kotlinx:kotlinx-io-core:0.9.0")
                implementation("com.github.ajalt.clikt:clikt:5.1.0")
            }
        }

        commonTest {
            dependencies {
                implementation(kotlin("test"))
            }
        }
    }
}

tasks.named<Jar>("jvmJar") {
    manifest {
        attributes["Main-Class"] = "benchmark.MainKt"
    }

    archiveFileName.set(
        if (kperfEnabled) "kotlin-instrumented.jar" else "kotlin-plain.jar"
    )
}

tasks.register<Copy>("copyJvmRuntimeDependencies") {
    from(configurations["jvmRuntimeClasspath"])
    into(layout.buildDirectory.dir("jvmRuntimeClasspath"))
}

tasks.named("build") {
    dependsOn("copyJvmRuntimeDependencies")
}