#!/bin/bash

function executeBenchmark() {
    # i comes from MooBench external loop
    local loop="${i}"
    local recursion="${RECURSION_DEPTH}"

    for index in $MOOBENCH_CONFIGURATIONS; do
        info " # ${loop}.${recursion}.${index} ${TITLE[$index]}"

        export JAVA_OPTS="${JAVA_ARGS} ${WRITER_CONFIG[$index]}"

        local RESULT_FILE="${RAWFN}-${loop}-${recursion}-${index}.csv"
        local LOG_FILE="${RESULTS_DIR}/output_${loop}_${recursion}_${index}.txt"

        "${MOOBENCH_BIN}" \
            --output-filename "${RESULT_FILE}" \
            --total-calls "${TOTAL_NUM_OF_CALLS}" \
            --method-time "${METHOD_TIME}" \
            --total-threads "${THREADS}" \
            --recursion-depth "${recursion}" \
            --application "moobench.application.MonitoredClassSimple" &> "${LOG_FILE}"

        sleep "${SLEEP_TIME}"
    done
}
