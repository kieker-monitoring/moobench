package benchmark

import application.MonitoredClass

expect class BenchmarkingThreadNano (mc: MonitoredClass,
                                     totalCalls: Int,
                                     methodTime: Long,
                                     recursionDepth: Int) : BenchmarkingThread {

    val executionTimes: LongArray
    override fun print(index: Int, separatorString: String) : String
    override fun run()

}