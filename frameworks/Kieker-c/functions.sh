# Kieker specific functions
# Kieker for C

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

function getAgent() {
  info "Setup Kieker4C"

  checkExecutable gcc $(which gcc)
  checkExecutable git "${GIT}"

  # note: if it already exists
  if [ -d "${KIEKER_4_C_DIR}" ]; then
    rm -rf "${KIEKER_4_C_DIR}"
  fi
  "${GIT}" clone "${KIEKER_4_C_REPO_URL}"
  checkDirectory kieker-c "${KIEKER_4_C_DIR}"
  cd "${KIEKER_4_C_DIR}"

  # get kieker for C
  mkdir "${MONITORING_LIB_DIR}"
  cd "${MONITORING_LIB_DIR}"

  git clone https://github.com/kieker-monitoring/kieker-lang-pack-c.git
  cd kieker-lang-pack-c/source/

  libtoolize
  aclocal
  autoconf
  automake --add-missing

  ./configure --prefix="${MONITORING_LIB_DIR}"
  make
  make install

  cd "${BASE_DIR}"
}

function instrumentBenchmark() {
  info "Building benchmark"

  dir=`pwd`
  cd "${SUT_C_DIR}"

  gcc benchmark.c -c -I /usr/include/glib-2.0/ -I /usr/lib/x86_64-linux-gnu/glib-2.0/include/

  # no instrumentation

  gcc monitored_application.c -c
  gcc benchmark.o monitored_application.o -o benchmark -l glib-2.0 -g

  # instrumentation
  gcc monitored_application.c -c -finstrument-functions

  gcc benchmark.o monitored_application.o -o benchmark -l glib-2.0 -g -l kieker -L "${MONITORING_LIB_DIR}/lib/" -o benchmark-instr -finstrument-functions -finstrument-functions-exclude-file-list=benchmark.c
  cd "${dir}"
}

# experiment setups

#################################
# function: execute an experiment

function createConfig() {
    instrument="$1"
    approach="$2"
    loop="$3"
  cat > "${CONFIG_INI_DIR}" << EOF
[Benchmark]
total_calls = ${TOTAL_NUM_OF_CALLS}
recursion_depth = ${RECURSION_DEPTH}
method_time = ${METHOD_TIME}
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
    instrument="$(cut -d " " -f2 <<< ${MONITORING_CONFIG[$config]})"
    selector="$(cut -d " " -f3 <<< ${MONITORING_CONFIG[$config]})"
    port="$(cut -d " " -f4 <<< ${MONITORING_CONFIG[$config]})"

    info " # ${loop}.${RECURSION_DEPTH}.${config} ${title}"

    RESULT_FILE="${RAWFN}-${loop}-${RECURSION_DEPTH}-${config}.csv"
    LOG_FILE="${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${config}.txt"

    createMonitoring ${mode} ${port}
    createConfig ${instrument} ${selector} ${loop}

    pushd "${SUT_C_DIR}"
    if [ $mode == "dummy" ] ; then
      MOOBENCH_BIN_C="${MOOBENCH_BIN_C_NOINSTR}"
    else
      MOOBENCH_BIN_C="${MOOBENCH_BIN_C_INSTR}"
    fi

    "${MOOBENCH_BIN_C}" "${CONFIG_INI_DIR}" &> ${LOG_FILE}
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
     # sleep is relevant to allow the receiver to come up before the C program is started
     sleep 5
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
  instrumentBenchmark
  for config in $MOOBENCH_CONFIGURATIONS; do
      executeBenchmarkBody $config $i
  done
}

# end
