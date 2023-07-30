JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")

function runAndStore {
	filePrefix=$1
	./benchmark.sh &> $JAVA_FOLDER/$filePrefix.txt
	mv results/results.zip $JAVA_FOLDER/$filePrefix.zip
}

mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=10; export SLEEP_TIME=5;

echo "Running Depth Experiments"
for depth in 2 10 20 50 75 100
do 
	echo -n "$depth.. "
	export RECURSION_DEPTH=$depth
	runAndStore depth_$depth
done
unset RECURSION_DEPTH

