#!/bin/bash
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
MAIN_DIR="${BASE_DIR}/../.."

if [ ! -d "${BASE_DIR}" ] ; then exit 1; fi
if [ -f "${MAIN_DIR}/init.sh" ] ; then source "${MAIN_DIR}/init.sh"; else exit 1; fi

MOOBENCH_CONFIGURATIONS="0 1 2 4"
echo "Running eBPF configurations: $MOOBENCH_CONFIGURATIONS"

cd "${BASE_DIR}"
checkDirectory data-dir "${DATA_DIR}" create
cleanupResults
mkdir -p $RESULTS_DIR
PARENT=$(dirname "${RESULTS_DIR}")
checkDirectory result-base "${PARENT}"

# Create Fake JAVA_HOME to force wrapper usage
FAKE_JAVA_HOME="${BASE_DIR}/fake_java_home"
mkdir -p "${FAKE_JAVA_HOME}/bin"

# Make the wrapper executable
chmod +x "${BASE_DIR}/java_wrapper.sh"

# Symlink the wrapper to be java in our fake home
ln -sf "${BASE_DIR}/java_wrapper.sh" "${FAKE_JAVA_HOME}/bin/java"

# Export this new JAVA_HOME so MooBench picks it up
export JAVA_HOME="${FAKE_JAVA_HOME}"
echo "Setting JAVA_HOME to: ${JAVA_HOME}"

JAVA_BIN="${BASE_DIR}/java_wrapper.sh"
# We check the wrapper, not system java
checkExecutable java "${JAVA_BIN}"
checkExecutable moobench "${MOOBENCH_BIN}"
checkFile R-script "${RSCRIPT_PATH}"

JAVA_ARGS="-Xms1G -Xmx2G"

declare -a WRITER_CONFIG
# 0: Baseline
WRITER_CONFIG[0]=""
# 1: Deactivated
WRITER_CONFIG[1]="-XX:+DTraceMethodProbes"
# 2: No collection (Count mode)
WRITER_CONFIG[2]="-XX:+DTraceMethodProbes -DEBPF_MODE=count"
# 4: Binary file (Write mode)
WRITER_CONFIG[4]="-XX:+DTraceMethodProbes -DEBPF_MODE=write"

executeAllLoops

rm -rf "${FAKE_JAVA_HOME}"

exit 0