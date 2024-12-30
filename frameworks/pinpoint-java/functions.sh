# OpenTelemetry specific functions

# ensure the script is sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

if [ -z "${BASE_DIR}" ] || [ ! -d $BASE_DIR ]
then
   echo "\$BASE_DIR was empty or not a directory; please set it before calling any function."
fi

function getAgent() {
    if [ ! -d "${BASE_DIR}/pinpoint" ]
    then
        mkdir -p "${BASE_DIR}/pinpoint"
        cd "${BASE_DIR}/pinpoint"
        wget --output-document=pinpoint.tar.gz \
            https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-agent/3.0.1/pinpoint-agent-3.0.1.tar.gz
        tar -xvf pinpoint.tar.gz
        cd $BASE_DIR
    fi
}

function getHBase() {
   if [ ! -d $BASE_DIR/hbase ]
   then
      mkdir -p $BASE_DIR/hbase
      wget https://dlcdn.apache.org/hbase/2.6.1/hbase-2.6.1-bin.tar.gz
      tar -xvf hbase-2.6.1-bin.tar.gz
      cd hbase-2.6.1
      wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/refs/heads/master/hbase/scripts/hbase-create.hbase
      cd $BASE_DIR
   fi
}

function startHBase() {
   cd hbase/hbase-2.6.1
   bin/start-hbase.sh
   
   wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/refs/heads/master/hbase/scripts/hbase-create.hbase
   
   bin/hbase shell hbase-create.hbase
}

function startPinot() {
	PINOT_VERSION=1.1.0 #set to the Pinot version you decide to use
	if [ ! -d apache-pinot-$PINOT_VERSION-bin ]
	then
		wget https://downloads.apache.org/pinot/apache-pinot-$PINOT_VERSION/apache-pinot-$PINOT_VERSION-bin.tar.gz
		tar -zxvf apache-pinot-$PINOT_VERSION-bin.tar.gz
	fi
	
	cd apache-pinot-$PINOT_VERSION-bin
	./bin/pinot-admin.sh QuickStart -type batch &> ${BASE_DIR}/logs/pinot.log
}

function startKafka() {
   if [ ! -d kafka_2.13-3.9.0 ]
   then
   	wget https://dlcdn.apache.org/kafka/3.9.0/kafka_2.13-3.9.0.tgz
   	tar -xvf kafka_2.13-3.9.0.tgz
   fi
   cd kafka_2.13-3.9.0

   KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
   bin/kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c config/kraft/reconfig-server.properties
   bin/kafka-server-start.sh config/kraft/reconfig-server.properties &> ${BASE_DIR}/logs/kafka.log &
   
   echo "Waiting for Kafka start..."
   sleep 3
   bin/kafka-topics.sh --create --topic inspector-stat-agent-00 --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1
   bin/kafka-topics.sh --create --topic inspector-stat-app --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1
}

function startCollectorAndWeb() {
   PINPOINT_VERSION=3.0.1

   if [ ! -f pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar ]
   then
      wget https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-collector-starter/${PINPOINT_VERSION}/pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar
   fi
   
   java -jar -Dpinpoint.zookeeper.address=localhost pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar &> ${BASE_DIR}/collector.log
   
   if [ ! -f pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar ]
   then
      wget https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-web-starter/${PINPOINT_VERSION}/pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar
   fi
   
   java -jar pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar &> ${BASE_DIR}/web-starter.log
   
   
}

function cleanup {
    [ -f "${BASE_DIR}/hotspot.log" ] && mv "${BASE_DIR}/hotspot.log" "${RESULTS_DIR}/hotspot-${i}-$RECURSION_DEPTH-${k}.log"
    echo >> "${BASE_DIR}/OpenTelemetry.log"
    echo >> "${BASE_DIR}/OpenTelemetry.log"
    sync
    sleep "${SLEEP_TIME}"
}

## Execute Benchmark
function executeBenchmark() {
   for index in $MOOBENCH_CONFIGURATIONS
   do
      case $index in
         0) runNoInstrumentation 0 ;;
         1) runPinpointBasic 1 ;;
      esac
      
      cleanup
   done
}


# experiment setups

function runNoInstrumentation {
    # No instrumentation
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    echo " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}" >> "${BASE_DIR}/OpenTelemetry.log"
    export BENCHMARK_OPTS="${JAVA_ARGS_NOINSTR}"
    "${MOOBENCH_BIN}" --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runPinpointBasic {
    # OpenTelemetry Instrumentation Logging Deactivated
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    echo " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]} >> "${BASE_DIR}/pinpoint.log"
    export BENCHMARK_OPTS="${JAVA_ARGS_PINTPOINT_BASIC}"
    "${MOOBENCH_BIN}" --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}


# end
