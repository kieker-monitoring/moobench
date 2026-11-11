#!/bin/bash

#
# Kieker python benchmark script
#
# Usage: benchmark.sh

if [ -z "${PYTHON}" ]; then
        PYTHON=`which python3`
else
        PYTHON=$(command -v "${PYTHON}")
fi

VENV_DIR=".venv"
${PYTHON} -m venv ${VENV_DIR}
source ${VENV_DIR}/bin/activate
PYTHON=$(which python)
PIP=$(which pip)

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
  echo "Setting default configuration $MOOBENCH_CONFIGURATIONS (everything)"
fi
echo "Running configurations: $MOOBENCH_CONFIGURATIONS"

checkFile receiver "receiver/receiver.jar"
checkFile R-script "${RSCRIPT_PATH}"

#
# Setup
#

info "----------------------------------"
info "Setup..."
info "----------------------------------"

cd "${BASE_DIR}"

# load agent
getAgent
instrumentBenchmark

checkDirectory data-dir "${DATA_DIR}" create
checkFile log "${DATA_DIR}/kieker.log" clean
cleanupResults
checkDirectory results-directory "${RESULTS_DIR}" recreate
PARENT=$(dirname "${RESULTS_DIR}")
checkDirectory result-base "${PARENT}"

# Find receiver and extract it

showParameter

TIME=$(expr ${METHOD_TIME} \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS} + ${SLEEP_TIME} \* 4 \* ${NUM_OF_LOOPS} \* ${RECURSION_DEPTH} + 50 \* ${TOTAL_NUM_OF_CALLS} / 1000000000 \* 4 \* ${RECURSION_DEPTH} \* ${NUM_OF_LOOPS})
info "Experiment will take circa ${TIME} seconds."

# Receiver setup if necessary
declare -a RECEIVER
# Title
declare -a TITLE

#
# Different monitoring & approach setups
# Properties
# - mode (dummy, tcp)
# - instrument (flag)
# - selector executable
# - port for tcp
#
MONITORING_CONFIG[0]="dummy False plain 0"
MONITORING_CONFIG[1]="tcp True instr 5678"
MONITORING_CONFIG[2]="tcp True instr-o3 5678"
RECEIVER[1]="java -jar receiver/receiver.jar 5678"
RECEIVER[2]="java -jar receiver/receiver.jar 5678"

executeAllLoops

deactivate
rm -rf ${VENV_DIR}

exit 0
# end
