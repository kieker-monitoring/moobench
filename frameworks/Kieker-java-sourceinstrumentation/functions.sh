# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi


function getAgent() {
	info "Download the Kieker agent ${AGENT}"
	# get agent
	export VERSION_PATH=`curl "https://oss.sonatype.org/service/local/repositories/snapshots/content/net/kieker-monitoring/kieker/" | grep '<resourceURI>' | sed 's/ *<resourceURI>//g' | sed 's/<\/resourceURI>//g' | grep '/$' | grep -v ".xml" | head -n 1`
	export AGENT_PATH=`curl "${VERSION_PATH}" | grep 'aspectj.jar</resourceURI' | sort | sed 's/ *<resourceURI>//g' | sed 's/<\/resourceURI>//g' | tail -1`
	curl "${AGENT_PATH}" > "${AGENT}"

	if [ ! -f "${AGENT}" ] ; then
		error "Kieker download from $AGENT_PATH seems to have failed; no file in $AGENT present."
		ls
		exit 1
	fi
	if [ ! -s "${AGENT}" ] ; then
		error "Kieker download from $AGENT_PATH seems to have failed; file in $AGENT has size 0."
		ls -lah
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
    echo " # ${loop}.${recursion}.${index} ${title}" >> "${DATA_DIR}/kieker.log"

    if [  "${kieker_parameters}" == "" ] ; then
       export BENCHMARK_OPTS="${JAVA_ARGS}"
    else
       export BENCHMARK_OPTS="${JAVA_ARGS} ${LTW_ARGS} ${KIEKER_ARGS} ${kieker_parameters}"
    fi

    debug "Run options: ${BENCHMARK_OPTS}"

    RESULT_FILE="${RAWFN}-${loop}-${recursion}-${index}.csv"
    LOG_FILE="${RESULTS_DIR}/output_${loop}_${RECURSION_DEPTH}_${index}.txt"


    if [ $index == 0 ]
    then
	    application=moobench.application.MonitoredClassSimple
	    APP_HOME=../../benchmark
	    CLASSPATH=$APP_HOME/lib/benchmark.jar:$APP_HOME/lib/jcommander-1.72.jar
    else
	    if [ $index == 5 ]
	    then
	    	application=moobench.application.MonitoredClassInstrumentedDiSLStyle
	    else
	    	application=moobench.application.MonitoredClassInstrumented
	    fi
	    APP_HOME=../../benchmark-kieker-instrumented
	    CLASSPATH=$APP_HOME/lib/benchmark-kieker-instrumented.jar:$APP_HOME/lib/jcommander-1.72.jar:$APP_HOME/lib/jctools-core-3.3.0.jar:$APP_HOME/lib/kieker-1.15.4.jar:$APP_HOME/lib/slf4j-api-1.7.30.jar
    fi
    
    
    sudo perf record -F 500 -a -g -o perf_"$index"_"$loop".data -- java -XX:+PreserveFramePointer $BENCHMARK_OPTS -cp $CLASSPATH \
		moobench.benchmark.BenchmarkMain \
	--application $application \
        --output-filename "${RESULT_FILE}" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads $THREADS \
        --recursion-depth "${recursion}" &> "${LOG_FILE}"
    sudo chown $(whoami):$(whoami) perf_"$index"_"$loop".data
    perf script -i perf_"$index"_"$loop".data | $FLAME_HOME/stackcollapse-perf.pl &> perf_"$index"_"$loop".folded
    cat perf_"$index"_"$loop".folded | $FLAME_HOME/flamegraph.pl &> perf_"$index"_"$loop".svg
    
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

    for index in $MOOBENCH_CONFIGURATIONS
    do
      executeBenchmarkBody $index $i $recursion
    done
}


# end
