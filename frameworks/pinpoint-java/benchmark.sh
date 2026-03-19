#!/bin/bash

#
# OpenTelemetry benchmark script
#
# Usage: benchmark.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
MAIN_DIR="${BASE_DIR}/../.."

if [ -z "$JAVA_HOME" ]; then
    echo "Pinpoint dependencies need JAVA_HOME to be set; please set it to start the benchmark"
    exit 1
fi

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
  MOOBENCH_CONFIGURATIONS="0 1 2 3 4"
  echo "Setting default configuration $MOOBENCH_CONFIGURATIONS (all Pinpoint configurations)"
fi
echo "Running configurations: $MOOBENCH_CONFIGURATIONS"
#
# Setup
#

info "----------------------------------"
info "Setup..."
info "----------------------------------"

# load agent
getAgent

checkDirectory results-directory "${RESULTS_DIR}" recreate

checkFile pinpoint-agent "${AGENT_JAR}"

checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=$(expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS} \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS})
info "Experiment will take circa ${TIME} seconds."

# general server arguments
JAVA_ARGS="-Xms1G -Xmx2G"

JAVA_ARGS_NOINSTR="${JAVA_ARGS}"
PINPOINT_BASIC="-javaagent:pinpoint/pinpoint-agent-${PINPOINT_VERSION}/pinpoint-bootstrap.jar -Dpinpoint.agentId=moobench-agent -Dpinpoint.applicationName=MOOBENCH "
JAVA_ARGS_PINTPOINT_DISABLED="${JAVA_ARGS} $PINPOINT_BASIC -Dpinpoint.disable=true"
JAVA_ARGS_PINTPOINT_NO_MEASUREMENT="${JAVA_ARGS} $PINPOINT_BASIC -Dprofiler.pinpoint.base-package="
JAVA_ARGS_PINTPOINT_BASIC="${JAVA_ARGS} $PINPOINT_BASIC -Dpinpoint.applicationName=MOOBENCH"
JAVA_ARGS_PINTPOINT_SAMPLING="${JAVA_ARGS} $PINPOINT_BASIC -Dprofiler.sampling.counting.sampling-rate=20"

writeConfiguration
checkMoobenchConfiguration

#
# Run benchmark
#

info "----------------------------------"
info "Running benchmark..."
info "----------------------------------"

## Execute Benchmark
for ((i = 1; i <= ${NUM_OF_LOOPS}; i += 1)); do
    k=0
    info "## Starting iteration ${i}/${NUM_OF_LOOPS}"
    echo "## Starting iteration ${i}/${NUM_OF_LOOPS}" >> "${BASE_DIR}/OpenTelemetry.log"

    executeBenchmark
    printIntermediaryResults "${i}"
done

# Create R labels
LABELS=$(createRLabels)
runStatistics

cleanupResults

mv "${BASE_DIR}/OpenTelemetry.log" "${RESULTS_DIR}/OpenTelemetry.log"
[ -f "${RESULTS_DIR}/hotspot-1-${RECURSION_DEPTH}-1.log" ] && grep "<task " "${RESULTS_DIR}/"hotspot-*.log > "${RESULTS_DIR}/java.log"
[ -f "${BASE_DIR}/errorlog.txt" ] && mv "${BASE_DIR}/errorlog.txt" "${RESULTS_DIR}"

checkFile results.yaml "${RESULTS_DIR}/results.yaml"
checkFile results.yaml "${RESULTS_DIR}/results.zip"

info "Done."

exit 0
# end
