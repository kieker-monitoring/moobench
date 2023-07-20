JAVA_FOLDER=$(java -version 2>&1 | grep version | tr " " "_" | tr -d "\"")
mkdir $JAVA_FOLDER
export NUM_OF_LOOPS=10; export SLEEP_TIME=5;

echo "Running Depth Experiments"
for depth in 2 10 20 50 75 100
do 
	echo -n "$depth.. "
	export RECURSION_DEPTH=$depth
	./benchmark.sh &> $JAVA_FOLDER/depth_$depth.txt
	mv results/results.zip $JAVA_FOLDER/depth_$depth.zip
done
unset RECURSION_DEPTH

