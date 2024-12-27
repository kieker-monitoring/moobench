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
	cd "${BASE_DIR}"
}


function startJaeger {
    if [ ! -d "${BASE_DIR}/jaeger-1.45.0-linux-amd64" ] ; then
        cd "${BASE_DIR}"
        wget https://github.com/jaegertracing/jaeger/releases/download/v1.45.0/jaeger-1.45.0-linux-amd64.tar.gz
        tar -xvf jaeger-1.45.0-linux-amd64.tar.gz
        rm jaeger-1.45.0-linux-amd64.tar.gz
    fi

    cd "${BASE_DIR}/jaeger-1.45.0-linux-amd64"
    "${BASE_DIR}/jaeger-1.45.0-linux-amd64/jaeger-all-in-one" --collector.otlp.enabled=True &> "${BASE_DIR}/jaeger-1.45.0-linux-amd64/jaeger.log" &
    cd "${BASE_DIR}"
}



# experiment setups

#################################
# function: execute an experiment

function createConfig() {
    instrument="$1"
    approach="$2"
    loop="$3"
cat > "${BASE_DIR}/config.ini" << EOF
[Benchmark]
total_calls = ${TOTAL_NUM_OF_CALLS}
recursion_depth = ${RECURSION_DEPTH}
method_time = ${METHOD_TIME}
config_path = ${BASE_DIR}/monitoring.ini
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
  
    createConfig False 1 $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"
    sync
    sleep "${SLEEP_TIME}"
}

function runWithNoExporter(){
    index="$1"
    loop="$2"
    
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    

    createConfig True 1 $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"


    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"

}

function runWithZipkin() {
    index="$1"
    loop="$2"
   
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    startZipkin
    createConfig True 2 $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"
    stopBackgroundProcess



    sync
    sleep "${SLEEP_TIME}"
}

function runWithJaeger(){
    index="$1"
    loop="$2"
    
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    startJaeger
    createMonitoring dummy
    createConfig True 3 $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    stopBackgroundProcess

    sync
    sleep "${SLEEP_TIME}"
}


function runWithPrometheus(){
    index="$1"
    loop="$2"
    
    
    info " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}"
    echo " # ${loop}.${RECURSION_DEPTH}.${index} ${TITLE[index]}" >> "${DATA_DIR}/kieker.log"
    startPrometheus 
    createConfig True 4 $loop
  
    "${PYTHON}" benchmark.py "${BASE_DIR}/config.ini" # &> "${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    stopBackgroundProcess

    sync
    sleep "${SLEEP_TIME}"
}

# end
