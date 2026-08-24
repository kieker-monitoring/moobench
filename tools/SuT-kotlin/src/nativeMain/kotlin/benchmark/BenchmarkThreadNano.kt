package benchmark

import application.MonitoredClass
import kotlin.time.TimeSource

actual class BenchmarkingThreadNano actual constructor(private val mc: MonitoredClass,
                                                       private val totalCalls: Int,
                                                       private val methodTime: Long,
                                                       private val recursionDepth: Int) : BenchmarkingThread {

    actual val executionTimes: LongArray = LongArray(totalCalls)
    //to prevent the (JIT) compiler from not calling the monitored method
    private val mcTimings: LongArray = LongArray(totalCalls)

    actual override fun print(index: Int, separatorString: String): String =
        "${executionTimes[index]}$separatorString"

    actual override fun run() {
        val timeSource = TimeSource.Monotonic
        for (i in 0..<this.totalCalls) {
            val start_ns = timeSource.markNow()
            mcTimings[i] = mc.monitoredMethod(this.methodTime, this.recursionDepth)
            val elapsed = start_ns.elapsedNow().inWholeNanoseconds
            executionTimes[i] = elapsed
            if ((i % 100000) == 0) {
                println(i)
            }
        }
    }
}