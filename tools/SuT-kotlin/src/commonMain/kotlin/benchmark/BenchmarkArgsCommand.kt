package benchmark

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.options.flag
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.options.required
import com.github.ajalt.clikt.parameters.types.int

class BenchmarkArgsCommand : CliktCommand(
    name = "benchmark"
) {
    val totalCalls by option("--total-calls", "-c").int().required()
    val methodTime by option("--method-time", "-m").int().required()
    val totalThreads by option("--total-threads", "-t").int().required()
    val recursionDepth by option("--recursion-depth", "-d").int().required()
    val outputFile by option("--output-filename", "-o").required()

    val quickstart by option("--quickstart", "-q").flag(default = false)
    val forceTerminate by option("--force-terminate", "-f").flag(default = false)

    val runnableClassname by option("--runnable", "-r")
    val applicationClassname by option("--application", "-a")

    lateinit var result: BenchmarkParameter
        private set

    override fun run() {
        result = BenchmarkParameter(
            totalCalls = totalCalls,
            methodTime = methodTime,
            totalThreads = totalThreads,
            recursionDepth = recursionDepth,
            outputFile = outputFile,
            quickstart = quickstart,
            forceTerminate = forceTerminate,
            runnableClassname = runnableClassname,
            applicationClassname = applicationClassname
        )
    }
}

