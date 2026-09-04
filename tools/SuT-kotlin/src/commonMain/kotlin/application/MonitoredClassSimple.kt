package application

import kotlin.time.TimeSource

class MonitoredClassSimple : MonitoredClass {
    override fun monitoredMethod(methodTime: Long, recDepth: Int): Long {
        if(recDepth > 1){
            return monitoredMethod(methodTime, recDepth - 1)
        }else {
            val start_time = TimeSource.Monotonic.markNow()
            var currentTime : Long
            do {
                currentTime = start_time.elapsedNow().inWholeNanoseconds
            }while(currentTime < methodTime)
            return currentTime
        }
    }
}