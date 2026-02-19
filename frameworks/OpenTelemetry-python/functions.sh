MOOBENCH_CONFIGURATIONS="0 1 2"
TITLE[0]="No Instrumentation"
TITLE[1]="OpenTelemetry No Export"
TITLE[2]="OpenTelemetry Zipkin"

export RECURSION_DEPTH="${RECURSION_DEPTH:-10}"

# helper to inject filename
function updateConfigFilename {
    local filename=$1
    grep -v "output_filename" "$CONFIG_TEMPLATE" > "$CONFIG_FILE"
    echo "output_filename = $filename" >> "$CONFIG_FILE"
}

function get_os_path {
    local raw_path=$1
    if command -v cygpath &>/dev/null; then cygpath -w "$raw_path"; else echo "$raw_path"; fi
}

function runNoInstrumentation {
    local k=$1
    local i=$2 
    
    # use the global RESULTS_DIR directly (Fixes the /output read-only error)
    local RAW_CSV="${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv"
    local CSV_FILE=$(get_os_path "$RAW_CSV")
    local LOG_FILE="${RESULTS_DIR}/output-raw-${i}-${RECURSION_DEPTH}-${k}.txt"
    
    echo " # Running Config $k: ${TITLE[$k]} (Iter $i)"
    
    updateConfigFilename "$CSV_FILE"
    export ENABLE_OTEL="false"
    
    python3 "$PYTHON_SCRIPT" "$CONFIG_FILE" > "$LOG_FILE" 2>&1
}

function runOpenTelemetryNoExport {
    local k=$1
    local i=$2
    
    local RAW_CSV="${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv"
    local CSV_FILE=$(get_os_path "$RAW_CSV")
    local LOG_FILE="${RESULTS_DIR}/output-raw-${i}-${RECURSION_DEPTH}-${k}.txt"
    
    echo " # Running Config $k: ${TITLE[$k]} (Iter $i)"
    updateConfigFilename "$CSV_FILE"
    
    export ENABLE_OTEL="true"
    export OTEL_TRACES_EXPORTER="none"
    export OTEL_METRICS_EXPORTER="none"
    export OTEL_LOGS_EXPORTER="none"
    
    python3 "$PYTHON_SCRIPT" "$CONFIG_FILE" > "$LOG_FILE" 2>&1
}

function runOpenTelemetryZipkin {
    local k=$1
    local i=$2
    
    local RAW_CSV="${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv"
    local CSV_FILE=$(get_os_path "$RAW_CSV")
    local LOG_FILE="${RESULTS_DIR}/output-raw-${i}-${RECURSION_DEPTH}-${k}.txt"
    
    startZipkin
    echo " # Running Config $k: ${TITLE[$k]} (Iter $i)"
    updateConfigFilename "$CSV_FILE"
    
    export ENABLE_OTEL="true"
    export OTEL_SERVICE_NAME="moobench-python"
    export OTEL_TRACES_EXPORTER="zipkin"
    export OTEL_EXPORTER_ZIPKIN_ENDPOINT="http://localhost:9411/api/v2/spans"
    export OTEL_METRICS_EXPORTER="none"
    export OTEL_LOGS_EXPORTER="none"
    
    python3 "$PYTHON_SCRIPT" "$CONFIG_FILE" > "$LOG_FILE" 2>&1

    stopBackgroundProcess
}

function executeBenchmark {
   for index in $MOOBENCH_CONFIGURATIONS
   do
      case $index in
         0) runNoInstrumentation 0 $i ;;
         1) runOpenTelemetryNoExport 1 $i ;;
         2) runOpenTelemetryZipkin 2 $i ;;
      esac
      sleep 1 
   done
}