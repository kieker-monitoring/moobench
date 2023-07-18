JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=30; export SLEEP_TIME=5;

echo
echo "Running DUMMY_LOOPS (in MonitoredClassLoops) Experiments"
for loops in 1 10 100 500 1000 2000 5000; do echo -n "$loops.. "; export DUMMY_LOOPS=$loops; ./benchmark.sh &> $JAVA_FOLDER/classDummy_$loops.txt; done
unset DUMMY_LOOPS
