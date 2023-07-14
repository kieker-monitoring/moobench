
function run {
	time=$1
	
	echo "Running METHOD_TIME $time"
	
	folder=METHOD_TIME_$time
	mkdir $folder
	
	export NUM_OF_LOOPS=1; export METHOD_TIME=$time; ./benchmark.sh &> $folder/log.txt
	./createGraphs.sh
	mv results $folder
	mv *.folded $folder
	mv *.svg $folder
	mv perf* $folder
}

run 1
run 2000
run 10000
run 100000
