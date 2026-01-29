#!/bin/bash

#
# OpenTelemetry benchmark script
#
# Usage: benchmark.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ ! -d "${BASE_DIR}" ] ; then
	echo "Base directory ${BASE_DIR} does not exist."
	exit 1
fi

MAIN_DIR="${BASE_DIR}/../.."

if [ -f "${MAIN_DIR}/init.sh" ] ; then
	source "${MAIN_DIR}/init.sh"
else
	echo "Missing library: ${MAIN_DIR}/init.sh"
	exit 1
fi

if [ -z "$MOOBENCH_CONFIGURATIONS" ]
then
	MOOBENCH_CONFIGURATIONS="0 1"
	echo "Setting default configuration $MOOBENCH_CONFIGURATIONS"
fi
echo "Running configurations: $MOOBENCH_CONFIGURATIONS"

#
# Setup
#

info "----------------------------------"
info "Setup..."
info "----------------------------------"

checkDirectory results-directory "${RESULTS_DIR}" recreate

JAVA_ARGS="-Xms1G -Xmx2G"
JAVA_ARGS_NOINSTR="${JAVA_ARGS}"

executeAllLoops

exit 0
