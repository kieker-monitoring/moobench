# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
	echo "Hey, you should source this script, not execute it!"
	exit 1
fi

function getAgent() {
	instrumentationTechnology="bytebuddy" # Replace by aspectj etc. if other technology is intended
	info "Download the Kieker agent ${AGENT_JAR}"
	SNAPSHOTS_URL_PREFIX="https://central.sonatype.com/repository/maven-snapshots/net/kieker-monitoring/kieker"
	KIEKER_VERSION=$(curl "${SNAPSHOTS_URL_PREFIX}/maven-metadata.xml" | grep '<latest>' | sed 's/ *<latest>//g' | sed 's/<\/latest>//g')
	AGENT_URL_PREFIX="${SNAPSHOTS_URL_PREFIX}/${KIEKER_VERSION}"
	AGENT_VERSION=$(curl ${AGENT_URL_PREFIX}/maven-metadata.xml | grep "$instrumentationTechnology" -A2 | grep '<value>' | sed 's/ *<value>//g' | sed 's/<\/value>//g')
	echo "Path: $VERSION_PATH"
	export AGENT_PATH="${AGENT_URL_PREFIX}/kieker-${AGENT_VERSION}-$instrumentationTechnology.jar"
	curl "${AGENT_PATH}" >"${AGENT_JAR}"

	if [ ! -f "${AGENT_JAR}" ]; then
		error "Kieker download from $AGENT_PATH seems to have failed; no file in $AGENT_JAR present."
		ls
		exit 1
	fi
	if [ ! -s "${AGENT_JAR}" ]; then
		error "Kieker download from $AGENT_PATH seems to have failed; file in $AGENT_JAR has size 0."
		ls -lah
		exit 1
	fi
}

function checkReceiverPort {
	if ss -tuln | grep -q ':2345'; then
		echo "Port 2345 is used - but the TCP receiver needs to be started there"
		exit 1
	fi
}

# experiment setups

#################################
# function: execute an experiment
#
# $1 = i iterator
# $2 = j iterator
# $3 = k iterator
# $4 = title
# $5 = writer parameters
function executeExperiment() {
	loop="$1"
	recursion="$2"
	index="$3"
	title="${TITLE[$index]}"
	kieker_parameters="${WRITER_CONFIG[$index]}"

	info " # ${loop}.${recursion}.${index} ${title}"

	if [ "${kieker_parameters}" == "" ]; then
		export BENCHMARK_OPTS="${JAVA_ARGS}"
	else
		export BENCHMARK_OPTS="${JAVA_ARGS} ${LTW_ARGS} ${KIEKER_ARGS} ${kieker_parameters}"
	fi

	debug "Run options: ${BENCHMARK_OPTS}"

	RESULT_FILE="${RAWFN}-${loop}-${recursion}-${index}.csv"
	LOG_FILE="${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

	"${MOOBENCH_BIN}" \
		--output-filename "${RESULT_FILE}" \
		--total-calls "${TOTAL_NUM_OF_CALLS}" \
		--method-time "${METHOD_TIME}" \
		--total-threads $THREADS \
		--recursion-depth "${recursion}" \
		${MORE_PARAMS} &>"${LOG_FILE}"

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

	[ -f "${DATA_DIR}/hotspot.log" ] && mv "${DATA_DIR}/hotspot.log" "${RESULTS_DIR}/hotspot-${loop}-${recursion}-${index}.log"
	sync
	sleep "${SLEEP_TIME}"
}

function executeBenchmarkBody() {
	index="$1"
	loop="$2"
	recursion="$3"
	if [[ "${RECEIVER[$index]}" ]]; then
		debug "receiver ${RECEIVER[$index]}"
		checkReceiverPort
		${RECEIVER[$index]} >>"${DATA_DIR}/kieker.receiver-${loop}-${index}.log" &
		RECEIVER_PID=$!
		debug "PID ${RECEIVER_PID}"
	fi

	executeExperiment "$loop" "$recursion" "$index"

	if [[ "${RECEIVER_PID}" ]]; then
		kill -TERM "${RECEIVER_PID}"
		unset RECEIVER_PID
	fi
}

function executeBenchmark() {
	recursion="${RECURSION_DEPTH}"

	for index in $MOOBENCH_CONFIGURATIONS; do
		executeBenchmarkBody $index $i $recursion
	done
}
