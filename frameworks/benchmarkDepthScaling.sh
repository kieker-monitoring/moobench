#!/bin/bash

function runAll {
	MODE=$1
	start=$(pwd)
	for benchmark in inspectIT-java OpenTelemetry-java Kieker-java Scouter-java elasticapm-java pinpoint-java Skywalking-java
	do
		echo "Running Depth Scaling $benchmark"
		if [ "$MODE" = "DEPTH" ]; then
			runDepthScaling "$benchmark"
		else
			runThreadScaling "$benchmark"
		fi
	done
}

function runThreadScaling {
	benchmark=$1
	cd "${benchmark}"

	RESULTS_DIR="parallel-results-${benchmark}"
	checkDirectory RESULTS_DIR "${RESULTS_DIR}" create
	
	for threads in 1 2 3 4
	do
		export THREADS=$threads
		echo "Running $threads"
		./benchmark.sh &> ${RESULTS_DIR}/parallel_$threads.txt
		if [ ! -f results-$benchmark/results.zip ]
		then
			echo "File results-$benchmark/results.zip missing; aborting"
			exit 1
		fi
		mv results-$benchmark/results.zip ${RESULTS_DIR}/results-$threads.zip
	done
	
	cd "${start}"
}

function runDepthScaling {
	benchmark=$1
	cd "${benchmark}"

	RESULTS_DIR="exp-results-${benchmark}"
	checkDirectory RESULTS_DIR "${RESULTS_DIR}" create
	
	for depth in 2 4 8 16 32 64 128
	do
		export RECURSION_DEPTH=$depth
		echo "Running $depth"
		./benchmark.sh &> ${RESULTS_DIR}/depth_$depth.txt
		if [ ! -f results-$benchmark/results.zip ]
		then
			echo "File results-$benchmark/results.zip missing; aborting"
			exit 1
		fi
		
		zip -jqr ${RESULTS_DIR}/output-$RECURSION_DEPTH.zip results-$benchmark/output_*
  		rm results-$benchmark/output_*
		
		mv results-$benchmark/results.zip ${RESULTS_DIR}/results-$RECURSION_DEPTH.zip
	done
	
	cd "${start}"
}

if [ -z "$JAVA_HOME" ]
then
    echo "Pinpoint dependencies need JAVA_HOME to be set; please set it before starting all benchmarks"
    exit 1
fi


# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -f "${BASE_DIR}/../common-functions.sh" ] ; then
	. "${BASE_DIR}/../common-functions.sh"
else
	echo "Missing configuration: ${BASE_DIR}/../common-functions.sh"
	exit 1
fi

if [[ -z "$1" ]]; then
	echo "Usage: $0 <ALL|foldername> <DEPTH|THREADS>"
	exit 1
fi

MODE=${2:-DEPTH}

echo "Running mode $MODE"

if [[ -z "$RECURSION_DEPTH" ]]
then
	echo "Warning: \$RECURSION_DEPTH is set to $RECURSION_DEPTH"
fi

case "$1" in
	ALL)
		runAll $MODE
	;;
	*)
		benchmark=$1
		if [ "$MODE" = "DEPTH" ]; then
			runDepthScaling "$benchmark"
		else
			runThreadScaling "$benchmark"
		fi
	;;
esac
