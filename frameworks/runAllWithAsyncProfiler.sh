

if [ -z "$ASYNC_PROFILER_HOME" ]
then
	echo "\$ASYNC_PROFILER_HOME needs to be defined (and a folder)"
	exit 1
fi

if [ -z "$JAVA_HOME" ]
then
    echo "Pinpoint dependencies need JAVA_HOME to be set; please set it before starting all benchmarks"
    exit 1
fi

export WARMUP_TIME=10

start=$(pwd)

# To execute using the "default" configuration of interest, we specify it individually for every framework

export MOOBENCH_CONFIGURATIONS="5"
cd Kieker-java
./benchmarks.sh
cd "${start}"

export MOOBENCH_CONFIGURATIONS="5"
cd OpenTelemetry-java
./benchmarks.sh
cd "${start}"

export MOOBENCH_CONFIGURATIONS="3"
cd inspectIT-java
./benchmarks.sh
cd "${start}"

