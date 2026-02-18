DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR/config.rc"

source "$DIR/functions.sh"
source "$DIR/../../common-functions.sh"

echo " # Preparing Environment..."
if [ -d "$VENV_DIR" ]; then rm -rf "$VENV_DIR"; fi

# For windows compatibility
if command -v python3 &>/dev/null; then
    PYTHON_EXE=python3
else
    PYTHON_EXE=python
fi

$PYTHON_EXE -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install -q --upgrade pip
pip install -q -r "$REQUIREMENTS_FILE"
opentelemetry-bootstrap -a install

cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

export NUM_OF_LOOPS=${NUM_OF_LOOPS:-10}
export TOTAL_NUM_OF_CALLS=${TOTAL_NUM_OF_CALLS:-2000000}
export RECURSION_DEPTH=${RECURSION_DEPTH:-10}
export METHOD_TIME=${METHOD_TIME:-0}
export SLEEP_TIME=${SLEEP_TIME:-15}

echo " # Starting Benchmark with $NUM_OF_LOOPS loops"
executeAllLoops

deactivate
rm "$CONFIG_FILE" 2>/dev/null
echo " # Completed."