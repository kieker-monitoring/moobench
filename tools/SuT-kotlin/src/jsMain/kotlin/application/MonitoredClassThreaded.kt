package application

import kotlin.time.TimeSource

// ThreadMXBean is JVM-only and not available on KMP common/native targets.
// We use TimeSource.Monotonic as a portable substitute to approximate user-time.
// Without ThreadMXBean we can't measure per-thread CPU user time;
// the monotonic clock only gives wall-clock elapsed time, so scheduling
// delays and other threads can skew the measurements.
actual class MonitoredClassThreaded :MonitoredClass {
    actual override fun monitoredMethod(methodTime: Long, recDepth: Int): Long {
        if(recDepth > 1){
            return monitoredMethod(methodTime, recDepth - 1)
        }else {
            val start_time = TimeSource.Monotonic.markNow()
            var currentTime : Long
            do {
                currentTime = start_time.elapsedNow().inWholeNanoseconds
            }while(currentTime < methodTime )
            return currentTime
        }
    }
}