JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=30; export SLEEP_TIME=5;

echo
echo "Running METHOD_TIME Experiments"
for mtime in 1 2000; do echo -n "$mtime.. "; export METHOD_TIME=$mtime; ./benchmark.sh &> $JAVA_FOLDER/time_$mtime.txt; done
unset METHOD_TIME
