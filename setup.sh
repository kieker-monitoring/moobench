#!/bin/bash

set -e

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

echo "Building tools"

./gradlew build

checkFile moobench "${MOOBENCH_ARCHIVE}"

echo "Extracting main benchmark"
tar -xpf "${MOOBENCH_ARCHIVE}"
MOOBENCH_BIN="${BASE_DIR}/benchmark/bin/benchmark"

echo "Extracting Kieker source instrumented benchmark"
checkFile moobench ${BASE_DIR}/tools/benchmark-kieker-instrumented/build/distributions/benchmark-kieker-instrumented.tar
tar -xpf ${BASE_DIR}/tools/benchmark-kieker-instrumented/build/distributions/benchmark-kieker-instrumented.tar

echo
echo "Generating javassist load time instrumented benchmark"
if [ -d benchmark-kieker-javassist ]
then
	rm -r benchmark-kieker-javassist
fi
cp benchmark benchmark-kieker-javassist -R
java -cp ../kieker/monitoring-buildtime/build/libs/monitoring-buildtime-2.0.0-SNAPSHOT.jar kieker.monitoring.buildtime.BuildTimeInstrumentationJavassist benchmark-kieker-javassist/lib/benchmark.jar

echo 
echo "Generating ByteBuddy load time instrumented benchmark"
if [ -d benchmark-kieker-bytebuddy ]
then
	rm -r benchmark-kieker-bytebuddy
fi
cp benchmark benchmark-kieker-bytebuddy -R
java -cp ../kieker/monitoring-buildtime/build/libs/monitoring-buildtime-2.0.0-SNAPSHOT.jar kieker.monitoring.buildtime.BuildTimeInstrumentationJavassist benchmark-kieker-bytebuddy/lib/benchmark.jar

echo "Generating AspectJ load time instrumented benchmark"
if [ -d benchmark-kieker-aspectj ]
then
	rm -r benchmark-kieker-aspectj
fi
cp benchmark benchmark-kieker-aspectj -R
java -cp ../kieker/monitoring-buildtime/build/libs/monitoring-buildtime-2.0.0-SNAPSHOT.jar kieker.monitoring.buildtime.BuildTimeInstrumentationAspectJ benchmark-kieker-aspectj/lib/benchmark.jar frameworks/Kieker-java/kieker.aop.xml


checkFile compile-result "${COMPILE_RESULTS_ARCHIVE}"
tar -xpf "${COMPILE_RESULTS_ARCHIVE}"
COMPILE_RESULTS_BIN="${BASE_DIR}/compile-results/bin/compile-results"

# end
