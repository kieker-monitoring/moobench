#!/bin/bash

#
# OpenTelemetry benchmark script
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

if [ -f "${MAIN_DIR}/common-functions.sh" ] ; then
	source "${MAIN_DIR}/common-functions.sh"
else
	echo "Missing library: ${MAIN_DIR}/common-functions.sh"
	exit 1
fi

# load configuration and common functions
if [ -f "${BASE_DIR}/config.rc" ] ; then
	source "${BASE_DIR}/config.rc"
else
	echo "Missing configuration: ${BASE_DIR}/config.rc"
	exit 1
fi

if [ -f "${BASE_DIR}/functions.sh" ] ; then
	source "${BASE_DIR}/functions.sh"
else
	echo "Missing: ${BASE_DIR}/functions.sh"
	exit 1
fi
if [ -f "${BASE_DIR}/labels.sh" ] ; then
	source "${BASE_DIR}/labels.sh"
else
	echo "Missing file: ${BASE_DIR}/labels.sh"
	exit 1
fi

#
# Setup
#

info "----------------------------------"
info "Setup..."
info "----------------------------------"

# load agent
getAgent

checkFile log "${BASE_DIR}/OpenTelemetry.log" clean
checkDirectory results-directory "${RESULTS_DIR}" recreate

checkFile opentelemetry-agent "${AGENT_JAR}"

checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=`expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS}  \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} `
info "Experiment will take circa ${TIME} seconds."

# general server arguments
JAVA_ARGS="-Xms1G -Xmx2G -verbose:gc"

JAVA_ARGS_NOINSTR="${JAVA_ARGS}"
JAVA_ARGS_OPENTELEMETRY_BASIC="${JAVA_ARGS} -javaagent:${AGENT_JAR} -Dotel.resource.attributes=service.name=moobench -Dotel.instrumentation.methods.include=moobench.application.MonitoredClassSimple[monitoredMethod];moobench.application.MonitoredClassThreaded[monitoredMethod]"
JAVA_ARGS_OPENTELEMETRY_LOGGING_DEACTIVATED="${JAVA_ARGS_OPENTELEMETRY_BASIC} -Dotel.traces.exporter=logging -Dotel.traces.sampler=always_off"
JAVA_ARGS_OPENTELEMETRY_LOGGING="${JAVA_ARGS_OPENTELEMETRY_BASIC} -Dotel.traces.exporter=logging"
JAVA_ARGS_OPENTELEMETRY_ZIPKIN="${JAVA_ARGS_OPENTELEMETRY_BASIC} -Dotel.traces.exporter=zipkin -Dotel.metrics.exporter=none"
JAVA_ARGS_OPENTELEMETRY_JAEGER="${JAVA_ARGS_OPENTELEMETRY_BASIC} -Dotel.traces.exporter=none -Dotel.traces.exporter=jaeger"
JAVA_ARGS_OPENTELEMETRY_PROMETHEUS="${JAVA_ARGS_OPENTELEMETRY_BASIC} -Dotel.traces.exporter=none -Dotel.metrics.exporter=prometheus"

writeConfiguration

#
# Run benchmark
#

info "----------------------------------"
info "Running benchmark..."
info "----------------------------------"

## Execute Benchmark
for ((i=1;i<=${NUM_OF_LOOPS};i+=1)); do
    k=0
    info "## Starting iteration ${i}/${NUM_OF_LOOPS}"
    echo "## Starting iteration ${i}/${NUM_OF_LOOPS}" >> "${BASE_DIR}/OpenTelemetry.log"

    runNoInstrumentation
    cleanup

    runOpenTelemetryNoLogging
    cleanup

    runOpenTelemetryLogging
    cleanup
    
    runOpenTelemetryZipkin
    cleanup
    
    runOpenTelemetryPrometheus
    cleanup

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
