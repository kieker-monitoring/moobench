#!/bin/bash

#
# Kieker moobench setup script
#
# Usage: setup.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

#
# source functionality
#

if [ ! -d "${BASE_DIR}" ] ; then
        echo "Base directory ${BASE_DIR} does not exist."
        exit 1
fi

# load configuration and common functions
if [ -f "${BASE_DIR}/config.rc" ] ; then
        source "${BASE_DIR}/config.rc"
else
        echo "Missing configuration: ${BASE_DIR}/config.rc"
        exit 1
fi

if [ -f "${BASE_DIR}/common-functions.sh" ] ; then
        source "${BASE_DIR}/common-functions.sh"
else
        echo "Missing library: ${BASE_DIR}/common-functions.sh"
        exit 1
fi

cd "${BASE_DIR}"

JAVA_VERSION=`java -version`

info "Java version ${JAVA_VERSION}"

./gradlew build

# Optionally build Kotlin benchmark artifacts

if [[ "$1" == "withKotlin" ]]; then
	mkdir -p frameworks/k-perf-kotlin/build/lib/deps
	mkdir -p frameworks/k-perf-kotlin/build/jsPlain/
	mkdir -p frameworks/k-perf-kotlin/build/jsInstrumented/
	mkdir -p frameworks/k-perf-kotlin/build/lib/
	
	# plain
	./gradlew build :tools:SuT-kotlin:build -PwithKotlin -PkperfEnabled=false
	cp tools/SuT-kotlin/build/jvmRuntimeClasspath/*.jar "frameworks/k-perf-kotlin/build/lib/deps/"
	cp "tools/SuT-kotlin/build/libs/kotlin-plain.jar" "frameworks/k-perf-kotlin/build/lib/"
	cp -r build/js/packages/kotlin-plain/kotlin/. \
		  frameworks/k-perf-kotlin/build/jsPlain/

	# instrumented
	./gradlew build :tools:SuT-kotlin:build -PwithKotlin -PkperfEnabled=true -PkPerfMethods="application.MonitoredClassSimple.monitoredMethod"
	cp "tools/SuT-kotlin/build/libs/kotlin-instrumented.jar" "frameworks/k-perf-kotlin/build/lib/"
	cp -r build/js/packages/kotlin-instrumented/kotlin/. \
		  frameworks/k-perf-kotlin/build/jsInstrumented/

	cp -r tools/SuT-kotlin/build/bin/. \
		  frameworks/k-perf-kotlin/build/bin/
fi


checkFile moobench "${MOOBENCH_ARCHIVE}"
tar -xpf "${MOOBENCH_ARCHIVE}"
MOOBENCH_BIN="${BASE_DIR}/benchmark/bin/benchmark"

checkFile compile-result "${COMPILE_RESULTS_ARCHIVE}"
tar -xpf "${COMPILE_RESULTS_ARCHIVE}"
COMPILE_RESULTS_BIN="${BASE_DIR}/compile-results/bin/compile-results"

# end
