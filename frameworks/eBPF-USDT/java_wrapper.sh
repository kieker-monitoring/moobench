#!/bin/bash

# Resolve BASE_DIR through symlinks
SCRIPT_PATH=$(readlink -f "$0")
BASE_DIR=$(cd "$(dirname "$SCRIPT_PATH")"; pwd)
TRACER_BIN="${BASE_DIR}/java_tracer_usdt"
DATA_OUT="${BASE_DIR}/data"

# Ceanup trap
cleanup() {
    if [ -n "$WATCHDOG_PID" ]; then kill $WATCHDOG_PID 2>/dev/null; fi
    if [ -n "$TRACER_PID" ]; then
        kill -SIGINT $TRACER_PID 2>/dev/null
        sleep 1
        kill -9 $TRACER_PID 2>/dev/null
    fi
    killall -9 java_tracer_usdt 2>/dev/null
    rm -f "$JAVA_STDOUT_LOG" 2>/dev/null
}
trap cleanup EXIT

# Find java
REAL_JAVA=$(which -a java | grep -v "fake_java_home" | head -n 1)
if [ -z "$REAL_JAVA" ]; then REAL_JAVA="/usr/bin/java"; fi

# 1. Parse Mode
MODE="none"
for arg in "$@"; do
    if [[ "$arg" == "-DEBPF_MODE=count" ]]; then MODE="count"; fi
    if [[ "$arg" == "-DEBPF_MODE=write" ]]; then MODE="write"; fi
done

# 2. Start Real Java
# For traced modes capture stdout to detect when measurement starts
if [ "$MODE" != "none" ]; then
    JAVA_STDOUT_LOG=$(mktemp /tmp/java_stdout.XXXXXX)

    # Use stdbuf to force line-buffered output from tee
    "$REAL_JAVA" "$@" > >(stdbuf -oL tee "$JAVA_STDOUT_LOG") 2>&1 &
    JAVA_PID=$!
else
    "$REAL_JAVA" "$@" &
    JAVA_PID=$!
fi

# START WATCHDOG
if [ "$MODE" == "write" ] || [ "$MODE" == "count" ]; then
    WATCHDOG_TIMEOUT=600
else
    WATCHDOG_TIMEOUT=120
fi
(
    sleep $WATCHDOG_TIMEOUT
    if kill -0 $JAVA_PID 2>/dev/null; then
        kill -9 $JAVA_PID
    fi
) &
WATCHDOG_PID=$!

# 3. Attach Tracer only when benchmark measurement begins
if [ "$MODE" != "none" ]; then
    # Wait for libjvm.so to be loaded
    MAX_RETRIES=50
    FOUND=0
    for ((i=0; i<MAX_RETRIES; i++)); do
        if ! kill -0 $JAVA_PID 2>/dev/null; then break; fi
        if grep -q "libjvm.so" /proc/$JAVA_PID/maps 2>/dev/null; then FOUND=1; break; fi
        sleep 0.1
    done

    if [ $FOUND -eq 1 ]; then
        # Wait for JVM startup to complete before attaching
        STARTUP_TIMEOUT=120
        READY=0
        for ((i=0; i<STARTUP_TIMEOUT*10; i++)); do
            # Check marker first
            if grep -q "Starting benchmark" "$JAVA_STDOUT_LOG" 2>/dev/null; then
                READY=1
                break
            fi
            if ! kill -0 $JAVA_PID 2>/dev/null; then
                # Java exited check file one last time
                sleep 0.2
                if grep -q "Starting benchmark" "$JAVA_STDOUT_LOG" 2>/dev/null; then
                    READY=1
                fi
                break
            fi
            sleep 0.1
        done

        if [ $READY -eq 1 ] && kill -0 $JAVA_PID 2>/dev/null; then
            if [ "$MODE" == "write" ]; then
                OUT_FILE="${DATA_OUT}/ebpf-trace-${JAVA_PID}.bin"
                "$TRACER_BIN" $JAVA_PID --mode=write --output="$OUT_FILE" >/dev/null 2>&1 &
                TRACER_PID=$!
            elif [ "$MODE" == "count" ]; then
                "$TRACER_BIN" $JAVA_PID --mode=count >/dev/null 2>&1 &
                TRACER_PID=$!
            fi
        fi
    fi
fi

# 4. Wait for Java
wait $JAVA_PID
EXIT_CODE=$?
exit $EXIT_CODE