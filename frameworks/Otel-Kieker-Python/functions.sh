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
empty_exporter = $empty
simple_processor = $simple

EOF
}

function emptySimpleExporter() {
    index="$1"
    loop="$2"
    

    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"

    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"

    createConfig  $loop True True

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function emptyBatchExporter() {
    index="$1"
    loop="$2"


    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"

    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"


    createConfig  $loop True False

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}



function kiekerSimpleExporter() {
    index="$1"
    loop="$2"


    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"

    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"


    createConfig  $loop False True

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function kiekerBatchExporter() {
    index="$1"
    loop="$2"


    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"

    ${RECEIVER_BIN} 5678 &
    RECEIVER_PID=$!
    echo $RECEIVER_PID
    sleep "${SLEEP_TIME}"


    createConfig  $loop False False

    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    kill -9 $RECEIVER_PID

    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}



# end
