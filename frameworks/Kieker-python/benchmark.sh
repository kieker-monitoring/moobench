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
	MOOBENCH_CONFIGURATIONS="0 1 2 3 4 5 6 7 8"
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

checkDirectory data-dir "${DATA_DIR}" create
checkFile log "${DATA_DIR}/kieker.log" clean
cleanupResults
checkDirectory results-directory "${RESULTS_DIR}" recreate
PARENT=`dirname "${RESULTS_DIR}"`
checkDirectory result-base "${PARENT}"

# Find receiver and extract it
checkFile receiver "receiver/receiver.jar"

checkFile R-script "${RSCRIPT_PATH}"

showParameter

TIME=`expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS}  \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} `
info "Experiment will take circa ${TIME} seconds."

# Receiver setup if necessary
declare -a RECEIVER
# Title
declare -a TITLE

#
# Different monitoring & approach setups
#
MONITORING_CONFIG[0]="dummy True False 1"
MONITORING_CONFIG[1]="dummy True True 1"
MONITORING_CONFIG[2]="dummy True True 2"
MONITORING_CONFIG[3]="dummy False True 1"
MONITORING_CONFIG[4]="dummy False True 2"
MONITORING_CONFIG[5]="text False True 1"
MONITORING_CONFIG[6]="text False True 2"
MONITORING_CONFIG[7]="tcp False True 1 5678"
MONITORING_CONFIG[8]="tcp False True 2 5679"
RECEIVER[7]="java -jar receiver/receiver.jar 5678"
RECEIVER[8]="java -jar receiver/receiver.jar 5679"

executeAllLoops

deactivate
rm -rf ${VENV_DIR}

exit 0
# end
