
function run {
	time=$1
	export NUM_OF_LOOPS=1; export METHOD_TIME=$time; ./benchmark.sh
	./createGraphs.sh
	folder=METHOD_TIME_$time
	mkdir $folder
	mv results $folder
	mv *svg $folder
	mv perf* $folder
}

run 1
run 2000
