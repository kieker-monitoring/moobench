#!/bin/bash

#
# Scouter benchmark script
#
# Usage: benchmark.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
MAIN_DIR="${BASE_DIR}/../.."

#
# source functionality
#

if [ ! -d "${BASE_DIR}" ]; then
  echo "Base directory ${BASE_DIR} does not exist."
  exit 1
fi

if [ -f "${MAIN_DIR}/init.sh" ]; then
  source "${MAIN_DIR}/init.sh"
else
  echo "Missing library: ${MAIN_DIR}/init.sh"
  exit 1
fi

if [ -z "$MOOBENCH_CONFIGURATIONS" ]; then
  MOOBENCH_CONFIGURATIONS="0 1 2"
  echo "Setting default configuration $MOOBENCH_CONFIGURATIONS"
fi
echo "Running configurations: $MOOBENCH_CONFIGURATIONS"

#
# Setup
#

info "----------------------------------"
info "Setup..."
info "----------------------------------"

cd "${BASE_DIR}"

# load agent
if [ ! -f $AGENT ]; then
  getAgent
fi

cleanupResults
mkdir -p $RESULTS_DIR
PARENT=$(dirname "${RESULTS_DIR}")
checkDirectory result-base "${PARENT}"

checkFile scouter.agent "${AGENT}"

checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=$(expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS} \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS})
info "Experiment will take circa ${TIME} seconds."

# general server arguments  -Xms1G -Xmx2G
JAVA_ARGS="-Xms1G -Xmx2G"

declare -a SCOUTER_CONFIG

SCOUTER_CONFIG[0]="${JAVA_ARGS}"

SCOUTER_CONFIG[1]="${SCOUTER_CONFIG[0]} -javaagent:${AGENT} -Dobj_name=moobench-benchmark -Dnet_collector_ip=127.0.0.1 -Dhook_service_patterns=${APP_CLASS}.monitoredMethod -Dhook_method_patterns=moobench.application.*.*"

SCOUTER_CONFIG[2]="${SCOUTER_CONFIG[1]} -Dprofile_method_enabled=false"

executeAllLoops

exit 0
# end
