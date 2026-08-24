package application

import java.lang.management.ManagementFactory
import java.lang.management.ThreadMXBean

actual class MonitoredClassThreaded : MonitoredClass {
    val threadMXBean: ThreadMXBean = ManagementFactory.getThreadMXBean()

    actual override fun monitoredMethod(methodTime: Long, recDepth: Int): Long {
        if (recDepth > 1) {
            return this.monitoredMethod(methodTime, recDepth - 1)
        } else {
            val exitTime: Long = this.threadMXBean.currentThreadUserTime + methodTime
            var currentTime: Long
            do {
                currentTime = this.threadMXBean.currentThreadUserTime
            } while (currentTime < exitTime)
            return currentTime
        }
    }
}