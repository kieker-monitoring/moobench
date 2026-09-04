package benchmark


data class BenchmarkParameter(
    val totalCalls: Int,
    val methodTime: Int,
    val totalThreads: Int,
    val recursionDepth: Int,
    val outputFile: String,
    val quickstart: Boolean,
    val forceTerminate: Boolean,
    val runnableClassname: String?,
    val applicationClassname: String?
)