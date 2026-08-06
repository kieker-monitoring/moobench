package application

expect class MonitoredClassThreaded() : MonitoredClass {
    override fun monitoredMethod(methodTime: Long, recDepth: Int): Long
}