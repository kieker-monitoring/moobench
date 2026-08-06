package benchmark

import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.promise

@OptIn(DelicateCoroutinesApi::class)
fun main(args: Array<String>) {
    GlobalScope.promise {
        BenchmarkMain.run(args)
    }
}