package benchmark

import application.MonitoredClass
import kotlin.time.TimeSource
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class BenchmarkingThreadMilli (private val mc: MonitoredClass, private val totalCalls: Int, private val methodTime: Long,
                              private val recursionDepth: Int) : BenchmarkingThread {
    private val timings: LongArray = LongArray(totalCalls)
    //to prevent the (JIT) compiler from not calling the monitored method
    private val mcTimings: LongArray = LongArray(totalCalls)
    private val mutex = Mutex()

    override fun run() {
        val timeSource = TimeSource.Monotonic
        for (i in 0..<this.totalCalls) {
            val start_ns = timeSource.markNow()
            mcTimings[i] = mc.monitoredMethod(this.methodTime, this.recursionDepth)
            val elapsed = start_ns.elapsedNow().inWholeMilliseconds
            timings[i] = elapsed
            if ((i % 100000) == 0) {
                println(i)
            }
        }
    }

    override fun print(index: Int, separatorString: String): String =
        timings[index].toString()


    suspend fun getTimings(): LongArray =
        mutex.withLock {
            timings.copyOf()
        }
}