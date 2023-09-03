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
	"${PIP}" install dist/kieker-monitoring-for-python-0.0.1.tar.gz
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
output_filename = ${RAWFN}-${loop}-${RECURSION_DEPTH}-${index}.csv
EOF
}

function createMonitoring() {
    mode="$1"
cat > "${BASE_DIR}/monitoring.ini" << EOF
[Main]
mode = ${mode}

[Tcp]
host = 127.0.0.1
port = 5678
connection_timeout = 10

[FileWriter]
file_path = ${DATA_DIR}/kieker
EOF
}

function noInstrumentation() {
    index="$1"
    loop="$2"
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
  
    createMonitoring dummy
    createConfig True False 1 $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function deactivatedProbe() {
    index="$1"
    loop="$2"
    approach="$3"
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
  
    createMonitoring dummy
    createConfig True True ${approach} $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"


    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function noLogging() {
    index="$1"
    loop="$2"
    approach="$3"
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    
    createMonitoring dummy
    createConfig False True ${approach} $loop
    
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"


    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function textLogging() {
    index="$1"
    loop="$2"
    approach="$3"
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"

    createMonitoring text
    createConfig False True ${approach} $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"


    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function tcpLogging() {
    index="$1"
    loop="$2"
    approach="$3"
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    
    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"
      
    createMonitoring tcp
    createConfig False True ${approach} $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

# end
