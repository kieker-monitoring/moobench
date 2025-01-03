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
	cd "${BASE_DIR}"
}



function executeBenchmark {
	runNoInstrumentation
    runScouter
}


function runNoInstrumentation() {
    # No instrumentation
	k=0
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    export BENCHMARK_OPTS="${JAVA_ARGS}"
    "${MOOBENCH_BIN}" \
		--output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runScouter() {
	# Scouter
	k=1
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    export BENCHMARK_OPTS="${SCOUTER_ARGS}"
    "${MOOBENCH_BIN}" \
		--output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}