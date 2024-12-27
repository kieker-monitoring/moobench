# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi


function getAgent() {
	info "Setup Kieker4Python"
	
	checkExecutable python "${PYTHON}"
	checkExecutable pip "${PIP}"
	checkExecutable git "${GIT}"
	"${PIP}" install -r requirements.txt
	# note: if it already exists
	if [ -d "${KIEKER_4_PYTHON_DIR}" ] ; then
		rm -rf "${KIEKER_4_PYTHON_DIR}"
	fi
	"${GIT}" clone "${KIEKER_4_PYTHON_REPO_URL}"
	checkDirectory kieker-python "${KIEKER_4_PYTHON_DIR}"
	cd "${KIEKER_4_PYTHON_DIR}"
	
	"${GIT}" checkout "${KIEKER_4_PYTHON_BRANCH}"
	"${PYTHON}" -m pip install --upgrade build
        "${PIP}" install decorator
	"${PYTHON}" -m build
	"${PIP}" install dist/kieker_monitoring_for_python-0.0.1.tar.gz

	cd "${BASE_DIR}"
}

# experiment setups

#################################
# function: execute an experiment

function createConfig() {
    loop="$1"
    empty="$2"
    simple="$3"
cat > "${BASE_DIR}/config.ini" << EOF
[Benchmark]
total_calls = ${TOTAL_NUM_OF_CALLS}
recursion_depth = ${RECURSION_DEPTH}
method_time = ${METHOD_TIME}
config_path = ${BASE_DIR}/monitoring.ini
output_filename = ${RAWFN}-${loop}-${RECURSION_DEPTH}-${index}.csv
instrumentation_on = $empty
batched_processor = $simple
latency_filename = latency-${loop}-${RECURSION_DEPTH}-${index}.csv

EOF
}

function getOtelCollector() {
    # Variables
    OTEL_COLLECTOR_URL="https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.86.0/otelcol_0.86.0_linux_amd64.tar.gz"
    OTEL_COLLECTOR_BINARY="otelcol"
    OTEL_COLLECTOR_DIR="./otel-collector"
    OTEL_COLLECTOR_CONFIG="${OTEL_COLLECTOR_DIR}/config.yaml"
    OTEL_COLLECTOR_PID_FILE="${OTEL_COLLECTOR_DIR}/otelcol.pid"
    OTEL_COLLECTOR_LOG_FILE="${OTEL_COLLECTOR_DIR}/otelcol.log"

    # Ensure the directory exists
    mkdir -p "$OTEL_COLLECTOR_DIR"

    # Check if the OpenTelemetry Collector binary exists
    if [[ ! -f "${OTEL_COLLECTOR_DIR}/${OTEL_COLLECTOR_BINARY}" ]]; then
        echo "Downloading OpenTelemetry Collector..."
        curl -L "$OTEL_COLLECTOR_URL" -o "${OTEL_COLLECTOR_DIR}/otelcol.tar.gz"
        echo "Extracting Collector..."
        tar -xzf "${OTEL_COLLECTOR_DIR}/otelcol.tar.gz" -C "$OTEL_COLLECTOR_DIR"
        chmod +x "${OTEL_COLLECTOR_DIR}/${OTEL_COLLECTOR_BINARY}"
        echo "Collector downloaded and ready."
    else
        echo "OpenTelemetry Collector is already downloaded."
    fi

    # Create a minimal configuration for the Collector to receive spans
    if [[ ! -f "$OTEL_COLLECTOR_CONFIG" ]]; then
        echo "Creating minimal configuration for the Collector..."
        cat <<EOF >"$OTEL_COLLECTOR_CONFIG"
receivers:
  otlp:
    protocols:
      http:
      grpc:

exporters:[]

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: []
EOF
        echo "Configuration created at $OTEL_COLLECTOR_CONFIG."
    else
        echo "Configuration already exists."
    fi

    # Start the OpenTelemetry Collector in the background
    echo "Starting OpenTelemetry Collector in the background..."
    "${OTEL_COLLECTOR_DIR}/${OTEL_COLLECTOR_BINARY}" --config "$OTEL_COLLECTOR_CONFIG" \
        >> "$OTEL_COLLECTOR_LOG_FILE" 2>&1 &
    echo $! > "$OTEL_COLLECTOR_PID_FILE"
    echo "Collector is running with PID $(cat "$OTEL_COLLECTOR_PID_FILE"). Logs are in $OTEL_COLLECTOR_LOG_FILE."
}

function noExporter() {
    index="$1"
    loop="$2"
    

    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"



    createConfig  $loop False True

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"


    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}





function kiekerSimpleExporter() {
    index="$1"
    loop="$2"

    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"

    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    


    createConfig  $loop True False

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function kiekerBatchedExporter() {
    index="$1"
    loop="$2"

    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"

    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    


    createConfig  $loop True True

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}






# end
