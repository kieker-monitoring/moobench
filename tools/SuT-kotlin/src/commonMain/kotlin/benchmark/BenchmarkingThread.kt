package benchmark

import kotlinx.coroutines.Runnable

interface BenchmarkingThread : Runnable {
    fun print(index: Int, separatorString: String) : String
}