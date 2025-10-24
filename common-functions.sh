#!/bin/bash

#
# Common functions used in scripts.
#

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

#
# functions
#

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

## Clean up raw results
function cleanupResults() {
  zip -jqr ${RESULTS_DIR}/results.zip ${RAWFN}*
  rm -f ${RAWFN}*
  [ -f ${DATA_DIR}/nohup.out ] && cp ${DATA_DIR}/nohup.out ${RESULTS_DIR}
  [ -f ${DATA_DIR}/nohup.out ] && > ${DATA_DIR}/nohup.out
}

function createRLabels() {
	# Create R labels
	LABELS=""
	for I in "${TITLE[@]}"
	do
		title="$I"
		if [ "$LABELS" == "" ] ; then
			LABELS="\"$title\""
		else
			LABELS="${LABELS}, \"$title\""
		fi
	done
	echo $LABELS
}

## Generate Results file
function runStatistics() {
   if [ "${TOTAL_NUM_OF_CALLS}" == 1 ] ; then
      export SKIP=0
   else
      export SKIP=${TOTAL_NUM_OF_CALLS}/2
   fi
   INDICES=$(echo $MOOBENCH_CONFIGURATIONS | tr " " ",")
   echo "Indices: $INDICES"
R --vanilla --silent << EOF
results_fn="${RAWFN}"
out_yaml_fn="${RESULTS_DIR}/results.yaml"
configs.loop=${NUM_OF_LOOPS}
configs.recursion=${RECURSION_DEPTH}
configs.labels=c($LABELS)
configs.framework_name="${FRAMEWORK_NAME}"
configs.indices=c($INDICES)
results.count=${TOTAL_NUM_OF_CALLS}
results.skip=${SKIP}
source("${RSCRIPT_PATH}")
EOF
}

function startZipkin {
	if [ ! -d "${BASE_DIR}/zipkin" ] || [ ! -f "${BASE_DIR}/zipkin/zipkin.jar" ]
	then
		mkdir -p "${BASE_DIR}/zipkin"
		cd "${BASE_DIR}/zipkin"
		curl -sSL https://zipkin.io/quickstart.sh | bash -s
	else
		cd "${BASE_DIR}/zipkin"
	fi
	java -Xmx6g -jar "${BASE_DIR}/zipkin/zipkin.jar" &> "${BASE_DIR}/zipkin/zipkin.txt" &
	pid=$!
	sleep 5
	cd "${BASE_DIR}"
}

function periodicallyCurlPrometheus {
	PROMETHEUS_PORT=$1
	sleep 5
	while [ true ]
	do
		echo "Curling for prometheus simulation..."
		curl localhost:$PROMETHEUS_PORT/metrics
		sleep 15
	done
}

function startPrometheus {
	periodicallyCurlPrometheus $1 &
	pid=$!
}

function stopBackgroundProcess {
	kill $pid
}

function writeConfiguration() {
	uname -a > "${RESULTS_DIR}/configuration.txt"
	"${JAVA_BIN}" ${JAVA_ARGS} -version 2>> "${RESULTS_DIR}/configuration.txt"
	cat << EOF >> "${RESULTS_DIR}/configuration.txt"
JAVA_ARGS: ${JAVA_ARGS}

Runtime: circa ${TIME} seconds

SLEEP_TIME=${SLEEP_TIME}
NUM_OF_LOOPS=${NUM_OF_LOOPS}
TOTAL_NUM_OF_CALLS=${TOTAL_NUM_OF_CALLS}
METHOD_TIME=${METHOD_TIME}
THREADS=${THREADS}
RECURSION_DEPTH=${RECURSION_DEPTH}
EOF
	sync
}

function getStatisticsOfMeasurementFile {
	RESULT_FILE=$1
	raw_length=`cat "${RESULT_FILE}" | wc -l`
	if [ "${raw_length}" == "0" ] ; then
		error "Result file '${RESULT_FILE}' is empty."
		exit 1
	fi
	CALLS_AFTER_WARMUP=$(($raw_length / 2))
	cat "${RESULT_FILE}" | awk -F';' '{print $2}' | getSum | tr "\n" " "
	tail -n $CALLS_AFTER_WARMUP "${RESULT_FILE}" | awk -F';' '{print $2}' | getSum
}

function printIntermediaryResults {
   loop="$1"
   for index in $MOOBENCH_CONFIGURATIONS
   do
      RESULT_FILE="${RAWFN}-${loop}-${RECURSION_DEPTH}-${index}.csv"
      checkFile result "${RESULT_FILE}"
      info_n "Intermediary results "${TITLE[$index]}" (in ns) "
      getStatisticsOfMeasurementFile ${RESULT_FILE}
   done
}

function checkMoobenchConfiguration {
	for configurationId in $MOOBENCH_CONFIGURATIONS
	do
		echo "Checking: $configurationId"
		label="${TITLE[$configurationId]}"
		echo "Label: $label"
		if [ -z "$label" ]
		then
			echo "Configuration is not defined: $configurationId"
			exit 1
		fi
	done
}

function executeAllLoops {
	writeConfiguration
	checkMoobenchConfiguration
	#
	# Run benchmark
	#

	info "----------------------------------"
	info "Running benchmark..."
	info "----------------------------------"

	for ((i=1;i<=${NUM_OF_LOOPS};i+=1))
	do
	    info "## Starting iteration ${i}/${NUM_OF_LOOPS}"

	    executeBenchmark
	    printIntermediaryResults "${i}"
	done
	
	# Create R labels
	LABELS=$(createRLabels)
	runStatistics

	cleanupResults
	
	checkFile results.yaml "${RESULTS_DIR}/results.yaml"
	checkFile results.yaml "${RESULTS_DIR}/results.zip"
	
	info "Done."
}

#
# reporting
#

export RED='\033[1;31m'
export WHITE='\033[1;37m'
export YELLOW='\033[1;33m'
export NC='\033[0m'

if [ "$BATCH_MODE" == "yes" ] ; then
	export ERROR="[error]"
	export WARNING="[warning]"
	export INFO="[info]"
	export DEBUG_INFO="[debug]"
else
	export ERROR="${RED}[error]${NC}"
	export WARNING="${YELLOW}[warning]${NC}"
	export INFO="${WHITE}[info]${NC}"
	export DEBUG_INFO="${WHITE}[debug]${NC}"
fi

function error() {
	echo -e "${ERROR} $@"
	if [ "${_STOP_ON_ERROR}" == "true" ] ; then
	   exit 1
	fi
}

function warn() {
	echo -e "${WARNING} $@"
}

function info() {
	echo -e "${INFO} $@"
}

function info_n() {
	echo -n -e "${INFO} $@"
}

function debug() {
	if [ "${DEBUG}" == "yes" ] ; then
		echo -e "${DEBUG_INFO} $@"
	fi
}

# $1 = NAME, $2 = EXECUTABLE
function checkExecutable() {
	if [ "$2" == "" ] ; then
		error "$1 variable for executable not set."
		exit 1
	fi
	if [ ! -x "$2" ] ; then
		error "$1 not found at: $2"
		exit 1
	fi
}

# $1 = NAME, $2 = FILE
function checkFile() {
	if [ "$2" == "" ] ; then
		error "$1 variable for file not set."
		exit 1
	fi
	if [ ! -f "$2" ] ; then
		if [ "$3" == "clean" ] ; then
			touch "$2"
		else
			error "$1 not found at: $2"
			exit 1
		fi
	else
		if [ "$3" == "clean" ] ; then
			info "$1 recreated, now empty"
			rm -f "$2"
			touch "$2"
		fi
	fi
}

# $1 = NAME, $2 = FILE
function checkDirectory() {
	if [ "$2" == "" ] ; then
		error "$1 directory variable not set."
		exit 1
	fi
	if [ ! -d "$2" ] ; then
		if [ "$3" == "create" ] || [ "$3" == "recreate" ] ; then
			info "$1: directory does not exist, creating it"
			mkdir -p "$2"
		else
			error "$1: directory $2 does not exist."
			exit 1
		fi
	else
		if [ "$3" == "recreate" ] ; then
			info "$1: exists, recreating it"
			rm -rf "$2"
			mkdir -p "$2"
		fi
	fi
}

function showParameter() {
	info "FRAMEWORK_NAME ${FRAMEWORK_NAME}"
	info "MOOBENCH_CONFIGURATIONS ${MOOBENCH_CONFIGURATIONS}"
	info "RESULTS_DIR ${RESULTS_DIR}"
	info "RAWFN ${RAWFN}"
	info "JAVA_BIN ${JAVA_BIN}"
	info "SLEEP_TIME ${SLEEP_TIME}"
	info "NUM_OF_LOOPS ${NUM_OF_LOOPS}"
	info "THREADS ${THREADS}"
	info "RECURSION_DEPTH ${RECURSION_DEPTH}"
	info "TOTAL_NUM_OF_CALLS ${TOTAL_NUM_OF_CALLS}"
	info "METHOD_TIME ${METHOD_TIME}"
	info "DEBUG ${DEBUG}"
}
