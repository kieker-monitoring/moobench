package benchmark

import kotlinx.coroutines.runBlocking

fun main(args: Array<String>) = runBlocking {
    BenchmarkMain.run(args)
}