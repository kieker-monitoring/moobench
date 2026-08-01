
function get_os_path {
    local raw_path=$1
    if command -v cygpath &> /dev/null; then cygpath -w "$raw_path"; else echo "$raw_path"; fi
}

function createOtelConfig() {
    loop="$1"
    filename="$2"
  cat > "${BASE_DIR}/config.ini" << EOF
[Benchmark]
total_calls = ${TOTAL_NUM_OF_CALLS}
recursion_depth = ${RECURSION_DEPTH}
method_time = ${METHOD_TIME}
config_path = ${BASE_DIR}/monitoring.ini
inactive = False
instrumentation_on = False
approach = 1
output_filename = $filename
EOF
	# Setting instrumentation_on to False is required to disable Kieker
}

function runNoInstrumentation {
    local k=$1
    local i=$2

    # Define Paths using variables from init.sh (RESULTS_DIR) and config.rc (RAWFN)
    local RAW_CSV="${RESULTS_DIR}/raw-${i}-${RECURSION_DEPTH}-${k}.csv"
    local CSV_FILE=$(get_os_path "$RAW_CSV")
    createOtelConfig $i $CSV_FILE
    
    local LOG_FILE="${RESULTS_DIR}/output-raw-${i}-${RECURSION_DEPTH}-${k}.txt"

    echo " # Running Config $k: ${TITLE[$k]} (Iter $i)"

    ENABLE_OTEL="false" \
    "${PYTHON}" "$MOOBENCH_BIN_PY" "$CONFIG_FILE" > "$LOG_FILE" 2>&1
}

function runOpenTelemetryNoExport {
    local k=$1
    local i=$2

    local RAW_CSV="${RESULTS_DIR}/raw-${i}-${RECURSION_DEPTH}-${k}.csv"
    local CSV_FILE=$(get_os_path "$RAW_CSV")
    createOtelConfig $i $CSV_FILE
    
    local LOG_FILE="${RESULTS_DIR}/output-raw-${i}-${RECURSION_DEPTH}-${k}.txt"

    echo " # Running Config $k: ${TITLE[$k]} (Iter $i)"

    ENABLE_OTEL="true" \
    OTEL_TRACES_EXPORTER="none" \
    OTEL_METRICS_EXPORTER="none" \
    OTEL_LOGS_EXPORTER="none" \
    "${PYTHON}" "$MOOBENCH_BIN_PY" "$CONFIG_FILE" > "$LOG_FILE" 2>&1
}

function runOpenTelemetryZipkin {
    local k=$1
    local i=$2
    
    local RAW_CSV="${RESULTS_DIR}/raw-${i}-${RECURSION_DEPTH}-${k}.csv"
    local CSV_FILE=$(get_os_path "$RAW_CSV")
    createOtelConfig $i $CSV_FILE
    
    local LOG_FILE="${RESULTS_DIR}/output-raw-${i}-${RECURSION_DEPTH}-${k}.txt"

    startZipkin
    echo " # Running Config $k: ${TITLE[$k]} (Iter $i)"

    ENABLE_OTEL="true" \
    OTEL_SERVICE_NAME="moobench-python" \
    OTEL_TRACES_EXPORTER="zipkin" \
    OTEL_EXPORTER_ZIPKIN_ENDPOINT="http://localhost:9411/api/v2/spans" \
    OTEL_METRICS_EXPORTER="none" \
    OTEL_LOGS_EXPORTER="none" \
    "${PYTHON}" "$MOOBENCH_BIN_PY" "$CONFIG_FILE" > "$LOG_FILE" 2>&1

    stopBackgroundProcess
}

function executeBenchmark {
   for index in $MOOBENCH_CONFIGURATIONS; do
      case $index in
         0) runNoInstrumentation 0 $i ;;
         1) runOpenTelemetryNoExport 1 $i ;;
         2) runOpenTelemetryZipkin 2 $i ;;
    esac
      sleep 1
  done
}
