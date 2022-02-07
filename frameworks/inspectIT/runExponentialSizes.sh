#!/bin/bash

RESULTS_DIR=results-inspectIT/
mkdir -p $RESULTS_DIR

for depth in 2 4 8 16 32 64 128
do
	export RECURSION_DEPTH=$depth
	echo "Running $depth"
	./benchmark.sh &> $RESULTS_DIR/$depth.txt
	mv $RESULTS_DIR/results.tar.xz $RESULTS_DIR/results-$RECURSION_DEPTH.zip
done
