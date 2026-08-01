# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

function getAgent() {
  info "Setup Kieker4Python"

  checkExecutable python $(which ${PYTHON})
  checkExecutable pip $(which ${PIP})
  checkExecutable git "${GIT}"

  # note: if it already exists
  if [ -d "${KIEKER_4_PYTHON_DIR}" ]; then
    rm -rf "${KIEKER_4_PYTHON_DIR}"
  fi
  "${GIT}" clone "${KIEKER_4_PYTHON_REPO_URL}"
  checkDirectory kieker-python "${KIEKER_4_PYTHON_DIR}"
  cd "${KIEKER_4_PYTHON_DIR}"

  "${GIT}" checkout "${KIEKER_4_PYTHON_BRANCH}"
  "${PYTHON}" -m pip install --upgrade pip build
  "${PIP}" install decorator
  "${PYTHON}" -m build
  "${PIP}" install dist/kieker_monitoring_for_python-0.0.2.tar.gz
  cd "${BASE_DIR}"
}

# experiment setups

#################################
# function: execute an experiment

function createConfig() {
    inactive="$1"
    instrument="$2"
    approach="$3"
    loop="$4"
  cat > "${BASE_DIR}/config.ini" << EOF
[Benchmark]
total_calls = ${TOTAL_NUM_OF_CALLS}
recursion_depth = ${RECURSION_DEPTH}
method_time = ${METHOD_TIME}
config_path = ${BASE_DIR}/monitoring.ini
inactive = $inactive
instrumentation_on = $instrument
approach = $approach
output_filename = ${RAWFN}-${loop}-${RECURSION_DEPTH}-${config}.csv
EOF
}

function createMonitoring() {
    local mode="$1"
    local port="$2"
    local tcp_section=""

    # Nur wenn der Modus tcp ist, bauen wir die Sektion zusammen
    if [[ "$mode" == "tcp" ]]; then
        tcp_section="[Tcp]
host = 127.0.0.1
port = ${port}
connection_timeout = 10"
  fi

    cat > "${BASE_DIR}/monitoring.ini" << EOF
[General]
multiple_Connections = False
[Main]
mode = ${mode}
${tcp_section}
[FileWriter]
file_path = ${DATA_DIR}/kieker-0.dat
EOF
}

#################################
# function: execute an experiment
function executeExperiment() {
    loop="$1"
    config="$2"
    title="${TITLE[$config]}"

    # Kieker-python specific parameters
    mode="$(cut -d " " -f1 <<< ${MONITORING_CONFIG[$config]})"
    inactive="$(cut -d " " -f2 <<< ${MONITORING_CONFIG[$config]})"
    instrument="$(cut -d " " -f3 <<< ${MONITORING_CONFIG[$config]})"
    approach="$(cut -d " " -f4 <<< ${MONITORING_CONFIG[$config]})"
    port="$(cut -d " " -f5 <<< ${MONITORING_CONFIG[$config]})"

    info " # ${loop}.${RECURSION_DEPTH}.${config} ${title}"

    RESULT_FILE="${RAWFN}-${loop}-${RECURSION_DEPTH}-${config}.csv"
    LOG_FILE="${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${config}.txt"

    createMonitoring ${mode} ${port}
    createConfig ${inactive} ${instrument} ${approach} ${loop}

    pushd "${SUT_PYTHON_DIR}"
    py-spy record -o profile-${loop}-${recursion}-${index}.svg -- "${PYTHON}" "${MOOBENCH_BIN_PY}" "${BASE_DIR}/config.ini" &> ${LOG_FILE}
    popd

    if [ ! -f "${RESULT_FILE}" ]; then
        info "---------------------------------------------------"
        cat "${LOG_FILE}"
        error "Result file '${RESULT_FILE}' is empty."
  else
       size=$(wc -c "${RESULT_FILE}" | awk '{ print $1 }')
       if [ "${size}" == "0" ]; then
           info "---------------------------------------------------"
           cat "${LOG_FILE}"
           error "Result file '${RESULT_FILE}' is empty."
    fi
  fi
    rm -rf "${DATA_DIR}"/kieker-*

    sync
    sleep "${SLEEP_TIME}"
}

function executeBenchmarkBody() {
  config="$1"
  loop="$2"
  if [[ "${RECEIVER[$config]}" ]]; then
     debug "receiver ${RECEIVER[$config]}"
     ${RECEIVER[$config]} >> "${DATA_DIR}/kieker.receiver-${loop}-${config}.log" &
     RECEIVER_PID=$!
     debug "PID ${RECEIVER_PID}"
  fi

  executeExperiment "$loop" "$config"

  if [[ "${RECEIVER_PID}" ]]; then
    if ps -p "${RECEIVER_PID}" > /dev/null; then
      kill -TERM "${RECEIVER_PID}"
    fi
     unset RECEIVER_PID
  fi
}

function executeBenchmark() {
    for config in $MOOBENCH_CONFIGURATIONS; do
      executeBenchmarkBody $config $i
  done
}

# end
