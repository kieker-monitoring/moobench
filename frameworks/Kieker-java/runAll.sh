JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=10; export SLEEP_TIME=1;
for depth in 2 10 20 50 75 100 200 300 400 500 600 750 1000; do export RECURSION_DEPTH=$depth; ./benchmark.sh &> $JAVA_FOLDER/depth_$depth.txt; done
unset RECURSION_DEPTH
for calls in 100 1000 10000 100000 1000000 2000000 10000000 100000000 1000000000; do export TOTAL_NUM_OF_CALLS=$calls; ./benchmark.sh &> $JAVA_FOLDER/calls_$calls.txt; done
unset TOTAL_NUM_OF_CALLS
for threads in {1..10}; do export THREADS=$threads; ./benchmark.sh &> $JAVA_FOLDER/threads_$threads.txt; done
unset THREADS
for loops in {1..20}; do export DUMMY_LOOPS=$loops; ./benchmark.sh &> $JAVA_FOLDER/dummy_$loops.txt; done
unset DUMMY_LOOPS
