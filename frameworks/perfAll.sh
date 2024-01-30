#!/bin/bash

for technology in Kieker-java Kieker-java-bytebuddy Kieker-java-javassist Kieker-java-sourceinstrumentation
do
	case "$technology" in
		"Kieker-java") export MOOBENCH_CONFIGURATIONS="4" ;;
		"Kieker-java-bytebuddy") export MOOBENCH_CONFIGURATIONS="4" ;;
		"Kieker-java-javassist") export MOOBENCH_CONFIGURATIONS="4" ;;
		"Kieker-java-DiSL") export MOOBENCH_CONFIGURATIONS="4" ;;
		"Kieker-java-sourceinstrumentation") export MOOBENCH_CONFIGURATIONS="3" ;;
		"OpenTelemetry-java") export MOOBENCH_CONFIGURATIONS="3" ;;
	esac

	cd $technology
	export NUM_OF_LOOPS=1; export TOTAL_NUM_OF_CALLS=10000000; ./benchmark.sh
	cd ..
done
