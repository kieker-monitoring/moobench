#!/bin/bash

#
# This scripts benchmarks all defined monitoring frameworks, currently:
# InspectIT, Kieker and OpenTelemetry"
#

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

cd "${BASE_DIR}"

start=$(pwd)
for benchmark in inspectIT-java OpenTelemetry-java Kieker-java Scouter-java elasticapm-java pinpoint-java Skywalking-java
do
	echo "Running $benchmark"
        cd "${benchmark}"
        ./benchmark.sh &> "${start}/log_${benchmark}.txt"
        cd "${start}"
done

# end
