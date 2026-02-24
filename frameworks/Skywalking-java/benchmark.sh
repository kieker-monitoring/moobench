#!/bin/bash

#
# Skywalking benchmark script
#
# Usage: benchmark.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
MAIN_DIR="${BASE_DIR}/../.."

#
# source functionality
#

if [ ! -d "${BASE_DIR}" ] ; then
	echo "Base directory ${BASE_DIR} does not exist."
	exit 1
fi

if [ -f "${MAIN_DIR}/init.sh" ] ; then
	source "${MAIN_DIR}/init.sh"
else
	echo "Missing library: ${MAIN_DIR}/init.sh"
	exit 1
fi

if [ -z "$MOOBENCH_CONFIGURATIONS" ]
then
	MOOBENCH_CONFIGURATIONS="0 1 2 3"
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
if [ ! -f $AGENT ]
then
	getAgent
fi

cleanupResults
mkdir -p $RESULTS_DIR
PARENT=`dirname "${RESULTS_DIR}"`
checkDirectory result-base "${PARENT}"

checkFile skywalking-agent "${AGENT}"
checkDirectory skywalking-apm "apache-skywalking-apm-bin"

checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=`expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS}  \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} `
info "Experiment will take circa ${TIME} seconds."

# general server arguments  -Xms1G -Xmx2G
JAVA_ARGS="-Xms1G -Xmx2G  --add-opens java.base/jdk.internal.misc=ALL-UNNAMED"

declare -a SKYWALKING_CONFIG

SKYWALKING_CONFIG[0]="${JAVA_ARGS}"

SKYWALKING_CONFIG[1]="${SKYWALKING_CONFIG[0]} -javaagent:${AGENT} -Dskywalking.agent.service_name=moobench::MooBench -Dskywalking.plugin.customize.enhance_file=${BASE_DIR}/customize_config/customize_enhance.xml"

SKYWALKING_CONFIG[2]="${SKYWALKING_CONFIG[1]} -Dskywalking.agent.sample_n_per_3_secs=60"

SKYWALKING_CONFIG[3]="${SKYWALKING_CONFIG[0]} -javaagent:${AGENT} -Dskywalking.agent.service_name=moobench::MooBench -Dskywalking.plugin.customize.enhance_file=${BASE_DIR}/customize_config_dummy/customize_enhance.xml"

executeAllLoops

exit 0
# end
