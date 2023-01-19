#!/bin/bash

#
# Kieker benchmark script
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

# This is necessary, as the framework name is originally
# derived from the directory the script is sitting in, but
# Kieker supports multiple languages and has multiple
# sub directories for each programming language.
export FRAMEWORK_NAME="kieker-${FRAMEWORK_NAME}"

cd "${BASE_DIR}"

# load agent
getAgent

checkDirectory data-dir "${DATA_DIR}" create
checkFile log "${DATA_DIR}/kieker.log" clean
checkDirectory results-directory "${RESULTS_DIR}" recreate
PARENT=`dirname "${RESULTS_DIR}"`
checkDirectory result-base "${PARENT}"

# Find receiver and extract it
checkFile receiver "${RECEIVER_ARCHIVE}"
tar -xpf "${RECEIVER_ARCHIVE}"
RECEIVER_BIN="${BASE_DIR}/receiver/bin/receiver"
checkExecutable receiver "${RECEIVER_BIN}"


checkFile ApsectJ-Agent "${AGENT}"
checkFile aop-file "${AOP}"


checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=`expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS}  \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} `
info "Experiment will take circa ${TIME} seconds."

# general server arguments
JAVA_ARGS="-Xms1G -Xmx2G"

LTW_ARGS[0]="-javaagent:${AGENT} -Dorg.aspectj.weaver.showWeaveInfo=true -Daj.weaving.verbose=true -Dkieker.monitoring.skipDefaultAOPConfiguration=true -Dorg.aspectj.weaver.loadtime.configuration=file://${AOP}"
LTW_ARGS[1]="-javaagent:${AGENT} -Dorg.aspectj.weaver.showWeaveInfo=true -Daj.weaving.verbose=true -Dkieker.monitoring.skipDefaultAOPConfiguration=true -Dorg.aspectj.weaver.loadtime.configuration=file://${AOP}"
LTW_ARGS[2]=""
LTW_ARGS[3]=""
LTW_ARGS[4]=""


KIEKER_ARGS="-Dlog4j.configuration=log4j.cfg -Dkieker.monitoring.name=KIEKER-BENCHMARK -Dkieker.monitoring.adaptiveMonitoring.enabled=false -Dkieker.monitoring.periodicSensorsExecutorPoolSize=0"

# JAVA_ARGS used to configure and setup a specific writer
declare -a WRITER_CONFIG
# Receiver setup if necessary
declare -a RECEIVER
# Title
declare -a TITLE

FILE_WRITER="-Dkieker.monitoring.enabled=true -Dkieker.monitoring.writer.filesystem.FileWriter.bufferSize=8192 -Dkieker.monitoring.writer=kieker.monitoring.writer.filesystem.FileWriter -Dkieker.monitoring.writer.filesystem.FileWriter.logStreamHandler=kieker.monitoring.writer.filesystem.BinaryLogStreamHandler"
CIRCULAR_QUEUE="-Dkieker.monitoring.core.controller.WriterController.RecordQueueFQN=org.apache.commons.collections4.queue.CircularFifoQueue -Dkieker.monitoring.core.controller.WriterController.QueuePutStrategy=kieker.monitoring.queue.putstrategy.YieldPutStrategy -Dkieker.monitoring.core.controller.WriterController.QueueTakeStrategy=kieker.monitoring.queue.takestrategy.YieldTakeStrategy"
#
# Different writer setups
#
WRITER_CONFIG[0]=""
WRITER_CONFIG[1]="$FILE_WRITER -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"
WRITER_CONFIG[2]="$FILE_WRITER -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"
WRITER_CONFIG[3]="$FILE_WRITER $CIRCULAR_QUEUE -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"
WRITER_CONFIG[4]="$FILE_WRITER -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"
WRITER_CONFIG[5]="$FILE_WRITER $CIRCULAR_QUEUE -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"
WRITER_CONFIG[6]="-Dkieker.monitoring.enabled=true -Dkieker.monitoring.writer=de.dagere.kopeme.kieker.writer.AggregatedTreeWriter -Dkieker.monitoring.writer.filesystem.FileWriter.bufferSize=8192 -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"
WRITER_CONFIG[6]="-Dkieker.monitoring.enabled=true $CIRCULAR_QUEUE -Dkieker.monitoring.writer=de.dagere.kopeme.kieker.writer.AggregatedTreeWriter -Dkieker.monitoring.writer.filesystem.FileWriter.bufferSize=8192 -Dkieker.monitoring.writer.filesystem.FileWriter.customStoragePath=${DATA_DIR}/"

BENCHMARK_MAIN[0]="moobench.application.MonitoredClassSimple"
BENCHMARK_MAIN[1]="moobench.application.MonitoredClassSimple"
BENCHMARK_MAIN[2]="moobench.application.sourceInstrumentation.MonitoredClassSimple"
BENCHMARK_MAIN[3]="moobench.application.sourceInstrumentation.MonitoredClassSimple"
BENCHMARK_MAIN[4]="moobench.application.durationRecord.MonitoredClassSimple"
BENCHMARK_MAIN[5]="moobench.application.durationRecord.MonitoredClassSimple"
BENCHMARK_MAIN[6]="moobench.application.aggregated.MonitoredClassSimple"
BENCHMARK_MAIN[7]="moobench.application.aggregated.MonitoredClassSimple"

writeConfiguration

#
# Run benchmark
#

info "----------------------------------"
info "Running benchmark..."
info "----------------------------------"

for ((i=1;i<="${NUM_OF_LOOPS}";i+=1)); do

    info "## Starting iteration ${i}/${NUM_OF_LOOPS}"
    echo "## Starting iteration ${i}/${NUM_OF_LOOPS}" >> "${DATA_DIR}/kieker.log"

    executeBenchmark

    printIntermediaryResults
done

# Create R labels
LABELS=$(createRLabels)
runStatistics

cleanupResults

mv "${DATA_DIR}/kieker.log" "${RESULTS_DIR}/kieker.log"
[ -f "${RESULTS_DIR}/hotspot-1-${RECURSION_DEPTH}-1.log" ] && grep "<task " "${RESULTS_DIR}/"hotspot-*.log > "${RESULTS_DIR}/java.log"
[ -f "${DATA_DIR}/errorlog.txt" ] && mv "${DATA_DIR}/errorlog.txt" "${RESULTS_DIR}"

checkFile results.yaml "${RESULTS_DIR}/results.yaml"
checkFile results.yaml "${RESULTS_DIR}/results.zip"

info "Done."

exit 0
# end
