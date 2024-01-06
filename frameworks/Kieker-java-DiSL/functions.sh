# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

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

    APP_HOME=../../benchmark
    CLASSPATH=$APP_HOME/lib/benchmark.jar:$APP_HOME/lib/jcommander-1.72.jar	

    KIEKER_DISL_JAR="../../../kieker/build/libs/kieker-2.0.0-SNAPSHOT-disl.jar"

    if [ ! -f $KIEKER_DISL_JAR ]
    then
        echo "It is expected that the Kieker DISL jar is available in \$KIEKER_DISL_JAR, but nothing found in $KIEKER_DISL_JAR"
        exit 1
    fi

    if [[ $index != 0 ]]
    then
    	
    
    	$DISL_HOME/bin/disl.py -d $DISL_HOME/output -s_noexcepthandler -cs -- \
   	 	 $KIEKER_DISL_JAR \
    		 -noverify -XX:-PrintWarnings \
    		 $kieker_parameters \
   	 	 -cp $CLASSPATH \
       	 moobench.benchmark.BenchmarkMain \
		--application moobench.application.MonitoredClassSimple \
	        --output-filename "${RESULT_FILE}" \
	        --total-calls "${TOTAL_NUM_OF_CALLS}" \
	        --method-time "${METHOD_TIME}" \
	        --total-threads 1 \
	        --recursion-depth "${recursion}" &> "${LOG_FILE}"
    else
    	java -cp $CLASSPATH \
		moobench.benchmark.BenchmarkMain \
		--application moobench.application.MonitoredClassSimple \
	        --output-filename "${RESULT_FILE}" \
	        --total-calls "${TOTAL_NUM_OF_CALLS}" \
	        --method-time "${METHOD_TIME}" \
	        --total-threads 1 \
	        --recursion-depth "${recursion}" &> "${LOG_FILE}"
    fi

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

    for ((index=0;index<${#WRITER_CONFIG[@]};index+=1)); do
      executeBenchmarkBody $index $i $recursion
    done
}


# end