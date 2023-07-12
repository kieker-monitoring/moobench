# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi


function getAgent() {
	info "Checking whether Kieker is present in ${AGENT}"
	if [ ! -f "${AGENT}" ] ; then
		# get agent
		export VERSION_PATH=`curl "https://oss.sonatype.org/service/local/repositories/snapshots/content/net/kieker-monitoring/kieker/" | grep '<resourceURI>' | sed 's/ *<resourceURI>//g' | sed 's/<\/resourceURI>//g' | grep '/$' | grep -v ".xml" | head -n 1`
		export AGENT_PATH=`curl "${VERSION_PATH}" | grep 'aspectj.jar</resourceURI' | sort | sed 's/ *<resourceURI>//g' | sed 's/<\/resourceURI>//g' | tail -1`
		curl "${AGENT_PATH}" > "${AGENT}"

		if [ ! -f "${AGENT}" ] || [ -s "${AGENT}" ] ; then
			error "Kieker download from $AGENT_PATH failed; please asure that a correct Kieker AspectJ file is present!"
		fi
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
    echo " # ${loop}.${recursion}.${index} ${title}" >> "${DATA_DIR}/kieker.log"

    if [  "${kieker_parameters}" == "" ] ; then
       export BENCHMARK_OPTS="${JAVA_ARGS}"
    else
       export BENCHMARK_OPTS="${JAVA_ARGS} ${LTW_ARGS} ${KIEKER_ARGS} ${kieker_parameters}"
    fi

    debug "Run options: ${BENCHMARK_OPTS}"

    RESULT_FILE="${RAWFN}-${loop}-${recursion}-${index}.csv"
    LOG_FILE="${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"

    if (( $THREADS > 1 ))
    then
           MONITORED_CLASS=moobench.application.MonitoredClassThreaded
    else
           MONITORED_CLASS=moobench.application.MonitoredClassSimple
    fi


    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp $CLASSPATH \
        moobench.benchmark.BenchmarkMain \
	--application $MONITORED_CLASS \
        --output-filename "${RESULT_FILE}" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads $THREADS \
        --recursion-depth "${recursion}" &> "${LOG_FILE}"

    if [ ! -f "${RESULT_FILE}" ] ; then
        info "---------------------------------------------------"
        cat "${LOG_FILE}"
        error "Result file '${RESULT_FILE}' is empty."
    else
       size=`wc -c "${RESULT_FILE}" | awk '{ print $1 }'`
       if [ "${size}" == "0" ] ; then
           info "---------------------------------------------------"
           cat "${LOG_FILE}"
           error "Result file '${RESULT_FILE}' is empty."
       fi
    fi
    rm -rf "${DATA_DIR}"/kieker-*

    [ -f "${DATA_DIR}/hotspot.log" ] && mv "${DATA_DIR}/hotspot.log" "${RESULTS_DIR}/hotspot-${loop}-${recursion}-${index}.log"
    echo >> "${DATA_DIR}/kieker.log"
    echo >> "${DATA_DIR}/kieker.log"
    sync
    sleep "${SLEEP_TIME}"
}

function executeBenchmarkBody() {
  index="$1"
  loop="$2"
  recursion="$3"
  if [[ "${RECEIVER[$index]}" ]] ; then
     debug "receiver ${RECEIVER[$index]}"
     ${RECEIVER[$index]} >> "${DATA_DIR}/kieker.receiver-${loop}-${index}.log" &
     RECEIVER_PID=$!
     debug "PID ${RECEIVER_PID}"
  fi

  executeExperiment "$loop" "$recursion" "$index"

  if [[ "${RECEIVER_PID}" ]] ; then
     kill -TERM "${RECEIVER_PID}"
     unset RECEIVER_PID
  fi
}

## Execute Benchmark
function executeBenchmark() {
    recursion="${RECURSION_DEPTH}"

    for index in 4; do
      executeBenchmarkBody $index $i $recursion
    done
}


# end
