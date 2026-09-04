package benchmark

import application.MonitoredClass
import java.lang.management.GarbageCollectorMXBean
import java.lang.management.ManagementFactory
import java.lang.management.MemoryMXBean
import kotlin.time.TimeSource


actual class BenchmarkingThreadNano actual constructor(private val mc: MonitoredClass,
                                                       private val totalCalls: Int,
                                                       private val methodTime: Long,
                                                       private val recursionDepth: Int) : BenchmarkingThread {

    actual val executionTimes: LongArray = LongArray(totalCalls)
    private val memory: MemoryMXBean = ManagementFactory.getMemoryMXBean()
    private val usedHeapMemory: LongArray = LongArray(totalCalls)
    private val gcCollectionCountDiffs: LongArray = LongArray(totalCalls)
    private val collector: List<GarbageCollectorMXBean> = ManagementFactory.getGarbageCollectorMXBeans()
    //to prevent the (JIT) compiler from not calling the monitored method
    private val mcTimings: LongArray = LongArray(totalCalls)

    actual override fun print(index: Int, separatorString: String): String =
        String.format(
            "%d%s%d%s%d",
            executionTimes[index], separatorString,
            usedHeapMemory[index], separatorString,
            gcCollectionCountDiffs[index]
        )

    actual override fun run() {
        var lastGcCount = this.computeGcCollectionCount()
        var currentGcCount: Long
        val timeSource = TimeSource.Monotonic

        for (i in 0..<this.totalCalls) {
            val start_ns = timeSource.markNow()
            mcTimings[i] = mc.monitoredMethod(this.methodTime, this.recursionDepth)
            val elapsed = start_ns.elapsedNow().inWholeNanoseconds
            currentGcCount = this.computeGcCollectionCount()
            executionTimes[i] = elapsed
            usedHeapMemory[i] = memory.heapMemoryUsage.used
            gcCollectionCountDiffs[i] = currentGcCount - lastGcCount
            lastGcCount = currentGcCount
            if ((i % 100000) == 0) {
                println(i)
            }
        }
    }

    private fun computeGcCollectionCount(): Long {
        var count: Long = 0
        for (bean in this.collector) {
            count += bean.collectionCount
        }
        return count
    }
}