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

echo " # Preparing Environment..."
if [ -d "$VENV_DIR" ]; then rm -rf "$VENV_DIR"; fi

# For Windows/Cygwin compatibility
if command -v python3 &> /dev/null; then
    PYTHON_EXE=python3
else
    PYTHON_EXE=python
fi

$PYTHON_EXE -m venv "$VENV_DIR"
if [ -f "$VENV_DIR/Scripts/activate" ]; then
    source "$VENV_DIR/Scripts/activate"
else
    source "$VENV_DIR/bin/activate"
fi

pip install -q --upgrade pip
pip install -q -r "$REQUIREMENTS_FILE"
opentelemetry-bootstrap -a install

cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

echo " # Starting Benchmark with $NUM_OF_LOOPS loops"
executeAllLoops

deactivate
echo " # Completed."
