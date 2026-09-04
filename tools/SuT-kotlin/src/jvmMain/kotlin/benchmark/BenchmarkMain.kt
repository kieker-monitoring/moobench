package benchmark

import application.MonitoredClass
import application.MonitoredClassThreaded
import com.github.ajalt.clikt.core.main
import com.github.ajalt.mordant.platform.MultiplatformSystem.exitProcess
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.io.Sink
import kotlinx.io.files.SystemFileSystem
import kotlinx.io.files.Path
import kotlinx.io.writeString
import kotlinx.io.buffered
import java.io.File
import kotlin.run
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.TimeSource

actual object BenchmarkMain {
    actual var sink: Sink? = null
    actual var parameter: BenchmarkParameter = BenchmarkParameter(
            totalCalls = 0,
            methodTime = 0,
            totalThreads = 1,
            recursionDepth = 1,
            outputFile = "",
            quickstart = false,
            forceTerminate = false,
            runnableClassname = null,
            applicationClassname = null
    )
    actual var monitoredClass: MonitoredClass? = null

    actual suspend fun run(args: Array<String>) {
        parseAndInitializeArguments(args)

        println(" # Experiment run configuration:")
        println(" # 1. Output filename " + parameter.outputFile)
        println(" # 2. Recursion Depth " + parameter.recursionDepth)
        println(" # 3. Threads " + parameter.totalThreads)
        println(" # 4. Total-Calls " + parameter.totalCalls)
        println(" # 5. Method-Time " + parameter.methodTime)

        val freeA = getFreeDiskSpaceKb()

        val benchmarkingThreads = arrayOfNulls<BenchmarkingThread>(parameter.totalThreads)

        if (!parameter.quickstart) {
            for (l in 0..3) {
                val freeMemChunks = Runtime.getRuntime().freeMemory() shr 27
                val memSize = 128 * 1024 * 128
                for (j in 0..<freeMemChunks) {
                    val grabMemory = LongArray(memSize)
                    for (i in 0..<memSize) {
                        grabMemory[i] = System.nanoTime()
                    }
                }
            }
            delay(5000.milliseconds)
        }

        val startTime = TimeSource.Monotonic.markNow()
        println(" # 6. Starting benchmark ...")
        try {
            coroutineScope {
                for (i in 0..<parameter.totalThreads) {
                    val benchmarkingThread = monitoredClass?.let {
                        BenchmarkingThreadNano(
                            it,
                            parameter.totalCalls,
                            parameter.methodTime.toLong(),
                            parameter.recursionDepth
                        )
                    }
                    benchmarkingThreads[i] = benchmarkingThread
                    if (benchmarkingThread != null) {
                        launch {
                            benchmarkingThread.run()
                        }
                    }
                }
            }
        }catch (e: Exception) {
            println("Benchmarking interrupted: ${e.message}")
            exitProcess(1)
        }

        val totalTime = startTime.elapsedNow().inWholeSeconds
        println(" #    done ($totalTime s)")

        print(" # 7. Writing results ... ")
        val out = sink ?: error("Output sink not initialized")
        out.use { s ->
            for (h in 0..<parameter.totalThreads) {
                val thread = benchmarkingThreads[h] ?: continue
                val threadName = (h + 1).toString()
                for (i in 0..<parameter.totalCalls) {
                    val line = "$threadName;${thread.print(i, ";")}\n"
                    s.writeString(line, 0, line.length)
                }
            }
            s.flush()
        }
        sink!!.close()

        println("done")
        println(" # ")

        val freeB = getFreeDiskSpaceKb()
        println("Disk usage: " + (freeA - freeB) + " kB")

        if (parameter.forceTerminate) {
            exitProcess(0)
        }
    }

    actual fun parseAndInitializeArguments(args: Array<String>) {
        try {
            parameter = parseArgs(args)
            sink = SystemFileSystem
                .sink(Path(parameter.outputFile), append = false)
                .buffered()

            parameter.applicationClassname?.let { className ->
                monitoredClass = Class.forName(className)
                    .getDeclaredConstructor()
                    .newInstance() as MonitoredClass
            } ?: run {
                monitoredClass = MonitoredClassThreaded()
            }
            parameter.runnableClassname?.let { className ->
                val runnableInstance = Class.forName(className)
                    .getDeclaredConstructor().newInstance() as Runnable
                runnableInstance.run()
            }
        } catch (e: Exception) {
            println("Error parsing arguments: ${e.message}")
            e.printStackTrace()
            exitProcess(1)
        }
    }

    actual fun getFreeDiskSpaceKb(): Long {
        val file = File(".")
        return file.freeSpace / 1024
    }

    actual fun parseArgs(args: Array<String>): BenchmarkParameter {
        val cmdArgs = BenchmarkArgsCommand()
        cmdArgs.main(args)
        return cmdArgs.result
    }
}




