# inspectIT specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

if [ -z "$ASYNC_PROFILER_HOME" ]
then
	echo "\$ASYNC_PROFILER_HOME needs to be defined (and a folder)"
	exit 1
fi

function getAgent() {
	if [ ! -f "${BASE_DIR}/agent/inspectit-ocelot-agent-$INSPECTIT_VERSION.jar" ] ; then
		mkdir "${BASE_DIR}/agent"
		cd "${BASE_DIR}/agent"
		wget https://github.com/inspectIT/inspectit-ocelot/releases/download/$INSPECTIT_VERSION/inspectit-ocelot-agent-$INSPECTIT_VERSION.jar
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

function executeBenchmark() {
   for index in $MOOBENCH_CONFIGURATIONS
   do
      case $index in
         0) runNoInstrumentation 0 ;;
         1) runInspectITDeactivated 1 ;;
         2) runInspectITNullWriter 2 ;;
         3) runInspectITZipkin 3 ;;
         4) runInspectITPrometheus 4 ;;
      esac
      
      cleanup
   done
}

# experiment setups

function runNoInstrumentation {
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    export BENCHMARK_OPTS="${JAVA_ARGS_NOINSTR}"
    sudo perf record -F 500 -g -o perf_"$index"_"$loop".data --delay $PERF_DELAY -- java -XX:+UnlockDiagnosticVMOptions -XX:+DumpPerfMapAtExit -XX:+PreserveFramePointer -XX:+DebugNonSafepoints \
        $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runInspectITDeactivated {
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_DEACTIVATED}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
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
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_NULLWRITER}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
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
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    startZipkin
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_ZIPKIN}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        --force-terminate \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt" &
    PID=$!
    sleep $WARMUP_TIME
    
    echo "Starting profiling of $PID"
    $ASYNC_PROFILER_HOME/bin/asprof \
        -o collapsed \
        -f "flamegraph_${i}_${RECURSION_DEPTH}_${k}.collapsed" \
        start $PID
    
    wait $PID
    
    stopBackgroundProcess
    sleep "${SLEEP_TIME}"
}

function runInspectITPrometheus {
    # InspectIT (minimal)
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    startPrometheus 8888
    sleep "${SLEEP_TIME}"
    export BENCHMARK_OPTS="${JAVA_ARGS_INSPECTIT_PROMETHEUS}"
    java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
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
