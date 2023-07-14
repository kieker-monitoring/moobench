JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=30; export SLEEP_TIME=5;

echo
echo "Running METHOD_TIME Experiments"
for space in "-Xmx1000m" "-Xmx1500m" "-Xmx2000m" "-Xmx2500m" "-Xmx3000m" "-Xmx3500m"
do
        echo "Memory: $space"
	export SPACE=$space
        for mtime in 1 10 100 1000 2000 10000; do echo -n "$mtime.. "; export METHOD_TIME=$mtime; ./benchmark.sh &> $JAVA_FOLDER/time_$mtime"_$space".txt; done
done
unset METHOD_TIME
