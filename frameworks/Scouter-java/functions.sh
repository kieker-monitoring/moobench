# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi


function getAgent() {
	if [ ! -d "${BASE_DIR}/scouter" ] ; then
		mkdir "${BASE_DIR}/scouter"
		cd "${BASE_DIR}"
		wget https://github.com/scouter-project/scouter/releases/download/v2.20.0/scouter-all-2.20.0.tar.gz
		tar -xvzf scouter-all-2.20.0.tar.gz
		sed -i 's@java@java --add-opens java.base/java.lang=ALL-UNNAMED --add-exports java.base/sun.net=ALL-UNNAMED @g' "${BASE_DIR}/scouter/server/startup.sh"
		cd "${BASE_DIR}"
	fi
}

function startScouterServer() {
	cd "${BASE_DIR}/scouter/server"
	./startup.sh
	cd "${BASE_DIR}"
}

function stopScouterServer() {
	cd "${BASE_DIR}/scouter/server"
	./stop.sh
	sleep 2
	rm -rf database/*
	cd "${BASE_DIR}"
}



function executeBenchmark {
    for index in $MOOBENCH_CONFIGURATIONS
   	do
      	runExperiment $index
    done
}


function runExperiment {
    # No instrumentation
	k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    if [[ "$k" -gt 0 ]]
    then
	    startScouterServer
    fi
    export BENCHMARK_OPTS="${SCOUTER_CONFIG[$k]}"
	java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
		-cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
		moobench.benchmark.BenchmarkMain \
		--output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt" &
       
	PID=$!
	if [[ -z "$WARMUP_TIME" ]]; then
		WARMUP_TIME=10
	fi
	sleep $WARMUP_TIME
    
	checkAsyncProf
	echo "Starting profiling of $PID"
	$ASYNC_PROFILER_HOME/bin/asprof \
		-o collapsed \
		-f "flamegraph_${i}_${RECURSION_DEPTH}_${k}.collapsed" \
		start $PID    
	wait $PID
        
    if [[ "$k" -gt 0 ]]
    then
	    stopScouterServer
    fi
}
