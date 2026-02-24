# Kieker specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

# Skywalking Java Agent version
AGENT_VERSION="9.6.0"
# Skywalking APM version
APM_VERSION="10.3.0"
# Skywalking BanyanDB version, check config/bydb.dependencies.properties in Skywalking apm for version
BANYANDB_VERSION="0.9.0"

# Gets the skywalking agent and APM server
# Commented code uses archive.apache.org which is too slow for Github actions but should be always available.
# The dlcdn.apache.org is much faster but only available for the latest version.
function getAgent {
	mkdir "${BASE_DIR}/skywalking-agent"
	cd "${BASE_DIR}"
  	#wget https://archive.apache.org/dist/skywalking/java-agent/${AGENT_VERSION}/apache-skywalking-java-agent-${AGENT_VERSION}.tgz
	wget https://dlcdn.apache.org/skywalking/java-agent/${AGENT_VERSION}/apache-skywalking-java-agent-${AGENT_VERSION}.tgz
	tar -xvzf apache-skywalking-java-agent-${AGENT_VERSION}.tgz
	cp "${BASE_DIR}/skywalking-agent/optional-plugins/apm-customize-enhance-plugin-${AGENT_VERSION}.jar" "${BASE_DIR}/skywalking-agent/plugins/"
	#wget https://archive.apache.org/dist/skywalking/${APM_VERSION}/apache-skywalking-apm-${APM_VERSION}.tar.gz
	wget https://dlcdn.apache.org/skywalking/${APM_VERSION}/apache-skywalking-apm-${APM_VERSION}-bin.tar.gz
	tar -xvzf apache-skywalking-apm-${APM_VERSION}-bin.tar.gz
	cd "${BASE_DIR}"
}

# Start banyandb as storage backend in a docker container and then the Skywalking APM server.
function startSkywalkingServer {
  docker pull apache/skywalking-banyandb:${BANYANDB_VERSION}-slim
  docker run -d -p 17912:17912 -p 17913:17913 --name banyandb \
    apache/skywalking-banyandb:${BANYANDB_VERSION}-slim standalone
  sleep 10
  cd "${BASE_DIR}/apache-skywalking-apm-bin/bin"
  ./oapService.sh &
  SKYWALKING_PID=$!
  cd "${BASE_DIR}"
  while ! nc -z localhost 11800; do
    sleep 2
  done
}

# Stops the APM server and then the banyandb container
function stopSkywalkingServer {
  if [[ -n "$SKYWALKING_PID" ]]; then
    kill "$SKYWALKING_PID"
    wait "$SKYWALKING_PID" 2>/dev/null
  fi
  # Empty the logs to avoid interference with next run
  echo "" > "${BASE_DIR}/apache-skywalking-apm-bin/logs/skywalking-oap-server.log"
  docker stop banyandb
  docker rm banyandb
	sleep 3
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
	    startSkywalkingServer
    fi
    export BENCHMARK_OPTS="${SKYWALKING_CONFIG[$k]}"
    "${MOOBENCH_BIN}" \
	--output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
    if [[ "$k" -gt 0 ]]
    then
	    stopSkywalkingServer
    fi
}
