#!/bin/bash

if [ ! -f $FLAME_HOME/flamegraph.pl ]
then
	echo "\$FLAME_HOME should be defined and point to a version of FlameGraph that contains flamegraph.pl"
fi

benchmarks="Kieker-java Kieker-java-bytebuddy Kieker-java-javassist Kieker-java-sourceinstrumentation OpenTelemetry-java"

if [ ! -z "$1" ] && [ $1 == "ALL" ]
then
	benchmarks="Kieker-java-aspectj-buildtime Kieker-java-bytebuddy-buildtime Kieker-java-javassist-buildtime $benchmarks"
	echo "Executing all benchmarks: $benchmarks"
else
	echo "Executing load time benchmarks: $benchmarks"	
fi

start=$(pwd)
for benchmark in $benchmarks
do
	case "$benchmark" in
		"Kieker-java-sourceinstrumentation") export MOOBENCH_CONFIGURATIONS="0 1 2 4 5" ;;
		"OpenTelemetry-java") export MOOBENCH_CONFIGURATIONS="0 1 3" ;;
		*) export MOOBENCH_CONFIGURATIONS="0 1 2 4" ;;
	esac

	cd $benchmark
	export NUM_OF_LOOPS=1; export TOTAL_NUM_OF_CALLS=10000000; ./benchmark.sh
	cd ..
done
