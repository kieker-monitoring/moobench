# inspectIT specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi


function getAgent() {
	if [ ! -d "${BASE_DIR}/agent" ] ; then
		mkdir "${BASE_DIR}/agent"
		cd "${BASE_DIR}/agent"
		wget https://github.com/inspectIT/inspectit-ocelot/releases/download/1.11.1/inspectit-ocelot-agent-1.11.1.jar
		cd "${BASE_DIR}"
	fi
}

function cleanup {
	[ -f "${BASE_DIR}/hotspot.log" ] && mv "${BASE_DIR}/hotspot.log" "${RESULTS_DIR}/hotspot-${i}-${j}-${k}.log"
	echo >> "${BASE_DIR}/inspectIT.log"
	echo >> "${BASE_DIR}/inspectIT.log"
	sync
	sleep "${SLEEP_TIME}"
}

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}


# experiment setups

function runNoInstrumentation {
    # No instrumentation
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    echo " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}" >> "${BASE_DIR}/inspectIT.log"
    export BENCHMARK_OPTS="${JAVA_ARGS_NOINSTR}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp $CLASSPATH \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runInspectITDeactivated {
    k=`expr ${k} + 1`
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    echo " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]} >> "${BASE_DIR}/inspectIT.log"
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_DEACTIVATED}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp $CLASSPATH \
        moobench.benchmark.BenchmarkMain \
         --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        --force-terminate \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
    sleep "${SLEEP_TIME}"
}

function runInspectITNullWriter {
    k=`expr ${k} + 1`
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    echo " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]} >>${BASE_DIR}/inspectIT.log
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_NULLWRITER}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp $CLASSPATH \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        --force-terminate \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
    sleep "${SLEEP_TIME}"
}


function runInspectITZipkin {
    # InspectIT (minimal)
    k=`expr ${k} + 1`
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    echo " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}" >> "${BASE_DIR}/inspectIT.log"
    startZipkin
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_ZIPKIN}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp $CLASSPATH \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        --force-terminate \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
    stopBackgroundProcess
    sleep "${SLEEP_TIME}"
}

function runInspectITPrometheus {
    # InspectIT (minimal)
    k=`expr ${k} + 1`
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    echo " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}" >> "${BASE_DIR}/inspectIT.log"
    startPrometheus
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_PROMETHEUS}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp $CLASSPATH \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        --force-terminate \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
    stopBackgroundProcess
    sleep $SLEEP_TIME
}

# end
