#!/bin/bash

#
# Kieker python benchmark script
#
# Usage: benchmark.sh

VENV_DIR="${HOME}/venv/moobench"
python3 -m venv ${VENV_DIR}
source ${VENV_DIR}/bin/activate

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
	echo "Missing functions: ${BASE_DIR}/functions.sh"
	exit 1
fi
if [ -f "${BASE_DIR}/labels.sh" ] ; then
	source "${BASE_DIR}/labels.sh"
else
	echo "Missing file: ${BASE_DIR}/labels.sh"
	exit 1
fi

if [ -z "$MOOBENCH_CONFIGURATIONS" ]
then
	MOOBENCH_CONFIGURATIONS="0 1 2 "
	echo "Setting default configuration $MOOBENCH_CONFIGURATIONS (everything)"
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
getAgent

checkFile log "${DATA_DIR}/kieker.log" clean
checkDirectory results-directory "${RESULTS_DIR}" recreate
PARENT=`dirname "${RESULTS_DIR}"`
checkDirectory result-base "${PARENT}"
checkDirectory data-dir "${DATA_DIR}" create

# Find receiver and extract it
checkFile receiver "${RECEIVER_ARCHIVE}"
tar -xpf "${RECEIVER_ARCHIVE}"
RECEIVER_BIN="${BASE_DIR}/receiver/bin/receiver"
checkExecutable receiver "${RECEIVER_BIN}"

checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=`expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS}  \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} `
info "Experiment will take circa ${TIME} seconds."

# Receiver setup if necessary
declare -a RECEIVER
# Title
declare -a TITLE

RECEIVER[5]="${RECEIVER_BIN} 2345"

#
# Write configuration
#

uname -a > "${RESULTS_DIR}/configuration.txt"
cat << EOF >> "${RESULTS_DIR}/configuration.txt"
Runtime: circa ${TIME} seconds

SLEEP_TIME=${SLEEP_TIME}
NUM_OF_LOOPS=${NUM_OF_LOOPS}
TOTAL_NUM_OF_CALLS=${TOTAL_NUM_OF_CALLS}
METHOD_TIME=${METHOD_TIME}
RECURSION_DEPTH=${RECURSION_DEPTH}
EOF

sync

info "Ok"

#
# Run benchmark
#

info "----------------------------------"
info "Running benchmark..."
info "----------------------------------"


## Execute Benchmark
for ((i=1;i<=${NUM_OF_LOOPS};i+=1)); do

    info "## Starting iteration ${i}/${NUM_OF_LOOPS}"
    echo "## Starting iteration ${i}/${NUM_OF_LOOPS}" >> "${DATA_DIR}/kieker.log"
    noExporter 0 $i
    kiekerSimpleExporter 1 $i
    kiekerBatchedExporter 2 $i
    
    
    

    

    printIntermediaryResults "${i}"
done

# Create R labels
LABELS=$(createRLabels)
runStatistics
cleanupResults

mv "${DATA_DIR}/kieker.log" "${RESULTS_DIR}/kieker.log"
rm "${DATA_DIR}/kieker"
[ -f "${DATA_DIR}/errorlog.txt" ] && mv "${DATA_DIR}/errorlog.txt" "${RESULTS_DIR}"

checkFile results.yaml "${RESULTS_DIR}/results.yaml"
checkFile results.yaml "${RESULTS_DIR}/results.zip"

info "Done."

deactivate
rm -rf ${VENV_DIR}

exit 0
# end
