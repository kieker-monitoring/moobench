#!/bin/bash

#
# k-perf benchmark script
#
# Usage: benchmark.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

#
# source functionality
#

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
	MOOBENCH_CONFIGURATIONS="0 1 2 3 4 5"
	echo "Setting default configuration $MOOBENCH_CONFIGURATIONS (without text logging)"
fi
echo "Running configurations: $MOOBENCH_CONFIGURATIONS"

#
# Setup
#

info "----------------------------------"
info "Setup..."
info "----------------------------------"

checkDirectory results-directory "${RESULTS_DIR}" recreate

checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=`expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS}  \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} `
info "Experiment will take circa ${TIME} seconds."

# general server arguments
JAVA_ARGS="-Xms1G -Xmx2G"

JAVA_ARGS_NOINSTR="${JAVA_ARGS}"


executeAllLoops

exit 0