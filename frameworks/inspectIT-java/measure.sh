#!/bin/bash

#
# inspectIT benchmark script
#
# Usage: benchmark.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

#
# source functionality
#

if [ ! -d "${BASE_DIR}" ]; then
  echo "Base directory ${BASE_DIR} does not exist."
  exit 1
fi

MAIN_DIR="${BASE_DIR}/../.."

if [ -f "${MAIN_DIR}/init.sh" ]; then
  source "${MAIN_DIR}/init.sh"
else
  echo "Missing library: ${MAIN_DIR}/init.sh"
  exit 1
fi

if [ -z "$MOOBENCH_CONFIGURATIONS" ]; then
  MOOBENCH_CONFIGURATIONS="0 1 2 3 4"
  echo "Setting default configuration $MOOBENCH_CONFIGURATIONS (everything)"
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

checkFile log "${BASE_DIR}/inspectIT.log" clean
checkDirectory results-directory "${RESULTS_DIR}" recreate

checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=$(expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS} \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS})
info "Experiment will take circa ${TIME} seconds."

# general server arguments
JAVA_ARGS="-Xms1G -Xmx2G -verbose:gc"

JAVA_ARGS_NOINSTR="${JAVA_ARGS}"
JAVA_ARGS_LTW="${JAVA_ARGS} -javaagent:${BASE_DIR}/agent/inspectit-ocelot-agent-$INSPECTIT_VERSION.jar -Dotel.instrumentation.logback.enabled=false"
JAVA_ARGS_INSPECTIT_DEACTIVATED="${JAVA_ARGS_LTW} -Dinspectit.service-name=moobench-inspectit -Dinspectit.exporters.metrics.prometheus.enabled=DISABLED -Dinspectit.exporters.tracing.zipkin.enabled=DISABLED -Dinspectit.config.file-based.path=${BASE_DIR}/config/onlyInstrument/"
JAVA_ARGS_INSPECTIT_NULLWRITER="${JAVA_ARGS_LTW} -Dinspectit.service-name=moobench-inspectit -Dinspectit.exporters.metrics.prometheus.enabled=DISABLED -Dinspectit.exporters.tracing.zipkin.enabled=DISABLED -Dinspectit.config.file-based.path=${BASE_DIR}/config/nullWriter/"
JAVA_ARGS_INSPECTIT_ZIPKIN="${JAVA_ARGS_LTW} -Dinspectit.service-name=moobench-inspectit -Dinspectit.exporters.metrics.prometheus.enabled=DISABLED -Dinspectit.exporters.tracing.zipkin.endpoint=http://127.0.0.1:9411/api/v2/spans -Dinspectit.config.file-based.path=${BASE_DIR}/config/zipkin/"
JAVA_ARGS_INSPECTIT_PROMETHEUS="${JAVA_ARGS_LTW} -Dinspectit.service-name=moobench-inspectit -Dinspectit.exporters.metrics.zipkin.enabled=DISABLED -Dinspectit.exporters.metrics.prometheus.enabled=ENABLED -Dinspectit.config.file-based.path=${BASE_DIR}/config/prometheus/"

executeAllLoops

exit 0
