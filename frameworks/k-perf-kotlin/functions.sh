# k-perf specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi


function cleanup {
	[ -f "${BASE_DIR}/hotspot.log" ] && mv ...

	mapfile -d '' files_to_delete < <(
	find "${BASE_DIR}" -type f \
		\( -name 'trace_*' -o -name 'symbols_*' \) -print0
	)

	if [ ${#files_to_delete[@]} -eq 0 ]; then
	echo "No trace_* or symbols_* files found."
	else
	echo "Found ${#files_to_delete[@]} trace/symbol file(s):"
	for file in "${files_to_delete[@]}"; do
		size_bytes=$(stat -c '%s' "$file")
		size_human=$(numfmt --to=iec-i --suffix=B "$size_bytes")
		line_count=$(wc -l < "$file")
		echo "  Size:  ${size_bytes} bytes (${size_human})"
		echo "  Lines: ${line_count}"
	done
	rm -f -- "${files_to_delete[@]}"
	echo "Cleanup completed."
	fi

	sync
	sleep "${SLEEP_TIME}"
 }

## Execute Benchmark
function executeBenchmark() {
   for index in $MOOBENCH_CONFIGURATIONS; do
      case $index in
         0) runNoInstrumentationJava 0 ;;
         1) runWithKPerfInstrumentationJava 1  ;;
         2) runNoInstrumentationNative 2 ;;
         3) runWithKPerfInstrumentationNative 3  ;;
         4) runNoInstrumentationJS 4 ;;
         5) runWithKPerfInstrumentationJS 5  ;;
    esac

      cleanup
  done
}

# experiment setups

function runNoInstrumentationJava {
    # No instrumentation
    k=$1
    info " # ${i}.${RECURSION_DEPTH}.${k} ${TITLE[$k]}"
	
    "${JAVA_BIN}" -cp "${MOOBENCH_JAR_PLAIN}" benchmark.MainKt \
        --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} \
        &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runWithKPerfInstrumentationJava {
    k=$1
    info " # ${i}.${RECURSION_DEPTH}.${k} ${TITLE[$k]}"

    "${JAVA_BIN}" -cp "${MOOBENCH_JAR_INSTRUMENTED}" benchmark.MainKt \
        --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} \
        &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}


function runNoInstrumentationNative() {
	k=$1
   info " # ${i}.${RECURSION_DEPTH}.${k} ${TITLE[$k]}"

   "${MOOBENCH_NATIVE_PLAIN_BIN}" \
      --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} \
        &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runWithKPerfInstrumentationNative() {
	k=$1
   info " # ${i}.${RECURSION_DEPTH}.${k} ${TITLE[$k]}"

   "${MOOBENCH_NATIVE_INSTR_BIN}" \
      --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} \
        &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runNoInstrumentationJS() {
   k=$1
   info " # ${i}.${RECURSION_DEPTH}.${k} ${TITLE[$k]}"

   "${NODE_BIN}" ${NODE_ARGS} "${MOOBENCH_JS_PLAIN_BIN}" \
      --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} \
        &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runWithKPerfInstrumentationJS() {
   k=$1
   info " # ${i}.${RECURSION_DEPTH}.${k} ${TITLE[$k]}"

   "${NODE_BIN}" ${NODE_ARGS} "${MOOBENCH_JS_INSTR_BIN}" \
      --output-filename "${RAWFN}-${i}-${RECURSION_DEPTH}-${k}.csv" \
      --total-calls "${TOTAL_NUM_OF_CALLS}" \
      --method-time "${METHOD_TIME}" \
      --total-threads "${THREADS}" \
      --recursion-depth "${RECURSION_DEPTH}" \
      ${MORE_PARAMS} \
      &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

# end