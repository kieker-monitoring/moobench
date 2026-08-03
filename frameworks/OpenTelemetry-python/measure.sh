#!/bin/bash

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

DIR=$(cd "$(dirname "$0")" && pwd)
RAW_MAIN_DIR="$DIR/../../"

if command -v cygpath &> /dev/null; then
    BASE_DIR=$(cygpath -w "$DIR")
    RAW_MAIN_DIR="$DIR/../../"
    MAIN_DIR=$(cygpath -w "$RAW_MAIN_DIR")
else
    BASE_DIR="$DIR"
    MAIN_DIR="$DIR/../../"
fi

# init.sh loads common-functions.sh and creates directories
if [ -f "${RAW_MAIN_DIR}/init.sh" ]; then
    source "${RAW_MAIN_DIR}/init.sh"
else
    echo "Missing library: ${RAW_MAIN_DIR}/init.sh"
    exit 1
fi

source "$DIR/config.rc"
source "$DIR/labels.sh"
source "$DIR/functions.sh"

if [ -z "$MOOBENCH_CONFIGURATIONS" ]; then
  MOOBENCH_CONFIGURATIONS="0 1 2"
  echo "Setting default configuration $MOOBENCH_CONFIGURATIONS"
fi

mkdir -p ${RESULTS_DIR}

pip install -q --upgrade pip
pip install -q -r "$REQUIREMENTS_FILE"
opentelemetry-bootstrap -a install

echo " # Starting Benchmark with $NUM_OF_LOOPS loops"
executeAllLoops

deactivate
echo " # Completed."
