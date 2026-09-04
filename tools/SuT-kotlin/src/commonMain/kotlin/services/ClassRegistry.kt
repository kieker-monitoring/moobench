package services

import application.MonitoredClass
import application.MonitoredClassSimple
import application.MonitoredClassThreaded
import benchmark.BenchmarkingThread
import benchmark.BenchmarkingThreadMilli
import benchmark.BenchmarkingThreadNano

typealias MonitoredFactory = () -> MonitoredClass

typealias BenchmarkingThreadFactory = (
    mc: MonitoredClass,
    totalCalls: Int,
    methodTime: Long,
    recursionDepth: Int
) -> BenchmarkingThread

object ClassRegistry {
    private val monitored = mutableMapOf<String, MonitoredFactory>()
    private val runnable = mutableMapOf<String, BenchmarkingThreadFactory>()

    init {
        registerMonitored("application.MonitoredClassSimple") {
            MonitoredClassSimple()
        }

        registerMonitored("application.MonitoredClassThreaded") {
            MonitoredClassThreaded()
        }
        registerRunnable("benchmark.BenchmarkingThreadMilli") { mc, totalCalls, methodTime, recursionDepth ->
            BenchmarkingThreadMilli(mc, totalCalls, methodTime, recursionDepth)
        }

        registerRunnable("benchmark.BenchmarkingThreadNano") { mc, totalCalls, methodTime, recursionDepth ->
            BenchmarkingThreadNano(mc, totalCalls, methodTime, recursionDepth)
        }
    }

    fun registerMonitored(name: String, factory: MonitoredFactory) {
        monitored[name] = factory
    }

    fun registerRunnable(name: String, factory: BenchmarkingThreadFactory) {
        runnable[name] = factory
    }

    fun createMonitored(name: String?): MonitoredClass? =
        name?.let { monitored[it]?.invoke() }

    fun createRunnable(
        name: String?,
        mc: MonitoredClass,
        totalCalls: Int,
        methodTime: Long,
        recursionDepth: Int
    ): BenchmarkingThread? =
        name?.let {
            runnable[it]?.invoke(mc, totalCalls, methodTime, recursionDepth)
        }

}