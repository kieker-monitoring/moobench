JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER

function runAndStore {
	filePrefix=$1
	./benchmark.sh &> $JAVA_FOLDER/$filePrefix.txt
	mv results/results.zip $JAVA_FOLDER/$filePrefix.zip
}


export NUM_OF_LOOPS=30; export SLEEP_TIME=5;
echo "Running Depth Experiments"
for depth in 2 10 20 50 75 100 200 300 400 500
do 
	echo -n "$depth.. ";
	export RECURSION_DEPTH=$depth
	runAndStore depth_$depth
done
unset RECURSION_DEPTH

echo
echo "Running Calls Experiments"
for calls in 100 1000 10000 100000 1000000 2000000 10000000
do 
	echo -n "$calls.. "
	export TOTAL_NUM_OF_CALLS=$calls
	runAndStore calls_$calls
done
unset TOTAL_NUM_OF_CALLS

#echo
#echo "Running Threads Experiments"
#for threads in {1..10}; do echo -n "$threads.. "; export THREADS=$threads; ./benchmark.sh &> $JAVA_FOLDER/threads_$threads.txt; done
#unset THREADS

echo
echo "Running Dummy Loops Experiments"
for loops in {1..20}
do 
	echo -n "$loops.. "
	export DUMMY_LOOPS=$loops
	runAndStore dummy_$loops
done
unset DUMMY_LOOPS

echo
echo "Running METHOD_TIME Experiments"
for mtime in 1 10 100 200 300 400 500 750 1000 2000 10000 20000
do 
	echo -n "$mtime.. "
	export METHOD_TIME=$mtime
	runAndStore time_$mtime
done
unset METHOD_TIME
