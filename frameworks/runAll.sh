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

if [ ! -f $DISL_HOME/bin/disl.py ]
then
	echo "Missing or wrong environment variable \$DISL_HOME"
	exit 1
fi

for agent_type in aspectj bytebuddy javassist disl
do
	AGENT_RAW_PATH="../../kieker/build/libs/kieker-2.0.0-SNAPSHOT-$agent_type.jar"
	if [ ! -f "${AGENT_RAW_PATH}" ]
	then
		error "Kieker agent for $agent_type in $AGENT_RAW_PATH not present; please build Kieker with an appropriate branch. (./gradlew mainJar aspectjJar bytebuddyJar dislJar  javassistJar -x test -x check)"
		ls
		exit 1
	fi
done

cd "${BASE_DIR}"

start=$(pwd)
for benchmark in Kieker-java Kieker-java-DiSL Kieker-java-bytebuddy Kieker-java-javassist Kieker-java-sourceinstrumentation OpenTelemetry-java
do
	case "$technology" in
		"Kieker-java-sourceinstrumentation") MOOBENCH_CONFIGURATIONS="0 1 3" ;;
		*) MOOBENCH_CONFIGURATIONS="0 1 4" ;;
	esac
	echo "Running $benchmark Configurations: $MOOBENCH_CONFIGURATIONS"
        cd "${benchmark}"
        ./benchmark.sh &> "${start}/log_${benchmark}.txt"
        cd "${start}"
done

# end
