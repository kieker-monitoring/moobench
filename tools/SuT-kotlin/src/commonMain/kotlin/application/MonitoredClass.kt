package application

interface MonitoredClass {
    fun monitoredMethod(methodTime : Long, recDepth : Int): Long
}