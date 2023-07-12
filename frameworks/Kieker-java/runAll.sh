JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=30; export SLEEP_TIME=5;

echo "Running Threads Experiments"
for threads in 2 3 4 5 1; do echo -n "$threads.. "; export THREADS=$threads; ./benchmark.sh &> $JAVA_FOLDER/threads_$threads.txt; done
unset THREADS

