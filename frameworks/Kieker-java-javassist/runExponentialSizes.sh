#!/bin/bash

#
# Run benchmark with increasing recursion depth.
#

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -f "${BASE_DIR}/../../common-functions.sh" ] ; then
	. "${BASE_DIR}/../../common-functions.sh"
else
	echo "Missing configuration: ${BASE_DIR}/../common-functions.sh"
	exit 1
fi

if [ -z "$EXPONENTIAL_SIZES" ]
then
	EXPONENTIAL_SIZES="2 4 8 16 32 64 128"
	echo "Setting default exponential sizes $EXPONENTIAL_SIZES"
fi
echo "Running exponential sizes: $EXPONENTIAL_SIZES"

RESULTS_DIR="${BASE_DIR}/exp-results"

#
# checks
#

checkDirectory RESULTS_DIR "${RESULTS_DIR}" create

#
# main
#

cd "${BASE_DIR}"
for depth in $EXPONENTIAL_SIZES
do
	export RECURSION_DEPTH=$depth
	echo "Running $depth"
	./benchmark.sh &> ${RESULTS_DIR}/$depth.txt
	mv results-Kieker-java-javaassist/results.zip ${RESULTS_DIR}/results-$RECURSION_DEPTH.zip
done

# end
