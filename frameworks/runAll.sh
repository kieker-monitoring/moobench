#!/bin/bash

#
# This scripts benchmarks all defined monitoring frameworks, currently:
# InspectIT, Kieker and OpenTelemetry"
#

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
for benchmark in Kieker-java Kieker-java-bytebuddy Kieker-java-javassist Kieker-java-sourceinstrumentation OpenTelemetry-java
do
	echo "Running $benchmark"
        cd "${benchmark}"
        ./benchmark.sh &> "${start}/log_${benchmark}.txt"
        cd "${start}"
done

# end
