package benchmark

import application.MonitoredClass
import kotlinx.io.Sink

expect object BenchmarkMain {
    var sink: Sink?
    var parameter: BenchmarkParameter
    var monitoredClass: MonitoredClass?

    suspend fun run(args: Array<String>)
    fun parseAndInitializeArguments(args: Array<String>)
    fun getFreeDiskSpaceKb(): Long
    fun parseArgs(args: Array<String>): BenchmarkParameter
}




