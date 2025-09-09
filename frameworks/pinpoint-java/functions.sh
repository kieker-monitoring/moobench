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
    if [ ! -f "${AGENT_JAR}" ]
    then
        mkdir -p "${BASE_DIR}/pinpoint"
        cd "${BASE_DIR}/pinpoint"
        curl -o pinpoint.tar.gz \
           https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-agent/$PINPOINT_VERSION/pinpoint-agent-"$PINPOINT_VERSION".tar.gz
        tar -xf pinpoint.tar.gz
        cd $BASE_DIR
    fi
}

export HBASE_VERSION=2.6.3

function startHBase() {
   echo "Starting HBase $HBASE_VERSION"
   if [ ! -d $BASE_DIR/hbase-$HBASE_VERSION ]
   then
      HBASE_URL=https://dlcdn.apache.org/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
      HBASE_URL_SHA512=https://dlcdn.apache.org/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz.sha512 
      curl --output hbase-$HBASE_VERSION-bin.tar.gz --limit-rate 5M $HBASE_URL
      curl --output hbase-$HBASE_VERSION-bin.tar.gz.sha512 --limit-rate 2M $HBASE_URL_SHA512
      
      checksum=$(cat hbase-"$HBASE_VERSION"-bin.tar.gz.sha512 | tr "\n" " " | awk -F':' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
      calculated_checksum=$(sha512sum hbase-"$HBASE_VERSION"-bin.tar.gz | awk '{print $1}')
      if [ "$checksum" != "$calculated_checksum" ]
      then
        echo "sha512sum of hbase couldn't be verified ($checksum vs $calculated_checksum; aborting"
        exit 1
      fi
      
      tar -xf hbase-$HBASE_VERSION-bin.tar.gz
   fi

   cd hbase-$HBASE_VERSION
   rm -rf tmp/zookeeper/* 
   rm -rf tmp/hbase/* 
   
   bin/start-hbase.sh | tee ${BASE_DIR}/logs/start-hbase.log
   
   if [ ! -f hbase-create.hbase ]
   then
      wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/refs/heads/master/hbase/scripts/hbase-create.hbase
   fi
   
   bin/hbase shell hbase-create.hbase &> ${BASE_DIR}/logs/hbase-create.log
   
   cd $BASE_DIR
}

function stopHBase(){
   echo "Stopping HBase $HBASE_VERSION"
   cd hbase-$HBASE_VERSION
   bin/stop-hbase.sh
   ps -aux | grep '[o]rg.apache.hadoop.hbase.master.HMaster' | awk '{print $2}' | xargs -r kill -9
   
   rm -rf tmp/zookeeper/* 
   rm -rf tmp/hbase/* 
   rm logs/*
   rm /tmp/hbase-* -r
   
   cd $BASE_DIR
}


export KAFKA_VERSION=2.13-3.9.0
function startKafka() {
   if [ ! -d kafka_$KAFKA_VERSION ]
   then
   	KAFKA_URL=https://dlcdn.apache.org/kafka/3.9.0/kafka_$KAFKA_VERSION.tgz
   	wget $KAFKA_URL
   	
   	tar -xf kafka_$KAFKA_VERSION.tgz
   fi
   cd kafka_$KAFKA_VERSION

   if [ -d /tmp/kraft-combined-logs ]
   then
     rm -rf /tmp/kraft-combined-logs
   fi
   KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
   bin/kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c config/kraft/reconfig-server.properties
   bin/kafka-server-start.sh config/kraft/reconfig-server.properties &> ${BASE_DIR}/logs/kafka.log &
   
   echo "Waiting for Kafka start..."
   sleep 3
   bin/kafka-topics.sh --create --topic inspector-stat-agent-00 --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1
   bin/kafka-topics.sh --create --topic inspector-stat-app --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1
   
   cd $BASE_DIR
}

function stopKafka {
   cd kafka_$KAFKA_VERSION
   bin/kafka-server-stop.sh
   
   rm logs/*
   rm /tmp/kraft-combined-logs/ -rf
   
   cd $BASE_DIR
}

function waitForStartup {
	fileName=$1
	textToWaitFor=$2
	
	sync
	sleep 5
	
	echo "Waiting for $fileName to contain $textToWaitFor"
	attempt=0
	while [ $attempt -le 150 ]; do
	    attempt=$(( $attempt + 1 ))
	    echo "Waiting for $fileName to contain $textToWaitFor (attempt: $attempt)..."
	    result=$(cat $fileName 2>&1)
	    if grep -q "$textToWaitFor" <<< $result ; then
	      echo "$fileName contains $textToWaitFor!"
	      ls -lah $fileName
	      echo "Result: $result"
	      ls -lah $fileName
	      break
	    fi
	    sleep 5
	done
	
	result=$(cat $fileName 2>&1)
	if ! grep -q "$textToWaitFor" <<< $result 
	then
		echo "$fileName doesn't contain $textToWaitFor even after waiting - exiting, please check download correctness"
		echo
		echo
		echo "File state: "
		ls -lah $fileName
		echo "File $fileName content:"
		cat $fileName
		exit 1
	fi
}

export PINOT_VERSION=1.3.0
function startPinot() {
   echo "Starting Pinot $PINOT_VERSION"
   if [ ! -d apache-pinot-$PINOT_VERSION-bin ]
   then
      PINOT_URL=https://downloads.apache.org/pinot/apache-pinot-$PINOT_VERSION/apache-pinot-$PINOT_VERSION-bin.tar.gz
      echo "Downloading $PINOT_URL"
      wget $PINOT_URL
      #curl --output apache-pinot-$PINOT_VERSION-bin.tar.gz $
         
      tar -zxf apache-pinot-$PINOT_VERSION-bin.tar.gz
   else
      rm -rf apache-pinot-$PINOT_VERSION-bin/pinot-temp-dir
   fi
	
   cd apache-pinot-$PINOT_VERSION-bin
   mkdir -p pinot-temp-dir
   ./bin/pinot-admin.sh QuickStart -type batch \
     -dataDir $(pwd)/pinot-temp-dir \
      &> ${BASE_DIR}/logs/pinot.log &
   
   waitForStartup ${BASE_DIR}/logs/pinot.log "***** Bootstrap tables *****"
   
   cd $BASE_DIR/scripts
   
   ./multi-table.sh 0 1 http://localhost:9000 &> ${BASE_DIR}/logs/pinot_multiTable.log
   
   cd $BASE_DIR
}

function stopPinot {
   kill -9 $(pgrep -f apache-pinot)
   
   rm /tmp/.pinotAdmin*
   rm /tmp/pinot-* -r
   rm -rf /tmp/Pinot*
   rm /tmp/PinotMinion -r
   rm apache-pinot-$PINOT_VERSION-bin/pinot-temp-dir -r
}

function startCollectorAndWeb() {
   cd pinpoint
   PINPOINT_VERSION=3.0.1

   if [ ! -f pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar ]
   then
      wget https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-collector-starter/${PINPOINT_VERSION}/pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar
   fi
   
   java -Dpinpoint.zookeeper.address=localhost -Dpinpoint.modules.realtime.enabled=false -jar pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar &> ${BASE_DIR}/logs/collector.log &
   
   waitForStartup ${BASE_DIR}/logs/collector.log "Started PinpointCollectorStarter in"
   
   
   if [ ! -f pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar ]
   then
      wget https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-web-starter/${PINPOINT_VERSION}/pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar
   fi
   
   java -Dpinpoint.zookeeper.address=localhost -Dpinpoint.modules.realtime.enabled=false -jar pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar &> ${BASE_DIR}/logs/web-starter.log &
    waitForStartup ${BASE_DIR}/logs/web-starter.log "Started PinpointWebStarter in"
   
   
   cd $BASE_DIR
}

function stopCollectorAndWeb() {
   kill -9 $(pgrep -f pinpoint-web-starter-)
   kill -9 $(pgrep -f pinpoint-collector-starter-)
}

function cleanup {
    sync
    sleep "${SLEEP_TIME}"
}

## Execute Benchmark
function executeBenchmark() {
   for index in $MOOBENCH_CONFIGURATIONS
   do
      case $index in
         0) runNoInstrumentation 0 ;;
         1) runPinpointBasic 1 "$JAVA_ARGS_PINTPOINT_DISABLED" ;;
         2) runPinpointBasic 2 "$JAVA_ARGS_PINTPOINT_NO_MEASUREMENT" ;;
         3) runPinpointBasic 3 "$JAVA_ARGS_PINTPOINT_BASIC" ;;
         4) runPinpointBasic 4 "$JAVA_ARGS_PINTPOINT_SAMPLING" ;;
      esac
      
      cleanup
   done
}


# experiment setups

function runNoInstrumentation {
    # No instrumentation
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    export BENCHMARK_OPTS="${JAVA_ARGS_NOINSTR}"
    "${MOOBENCH_BIN}" --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function startPinpointServers {
   mkdir -p logs

   startHBase
   startKafka
   startPinot
   
   startCollectorAndWeb
}

function stopPinpointServers {
   stopCollectorAndWeb
   stopKafka
   stopPinot
   stopHBase
   
   # No clue which tool creates these, but they are created...
   rm /tmp/tomcat* -r
}

function setPinpointConfig {
   sed -i 's/DEBUG/INFO/g' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/log4j2-agent.xml
   sed -i '/profiler.entrypoint/a profiler.transport.grpc.span.sender.executor.queue.size=100000' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   sed -i '/profiler.entrypoint/a profiler.pinpoint.base-package=moobench.application' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   sed -i 's|^profiler.entrypoint=.*|profiler.entrypoint=moobench.application.MonitoredClassSimple.monitoredMethod|' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   sed -i 's|^profiler.include=.*|profiler.include=moobench.application*|' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   sed -i 's|^profiler.sampling.counting.sampling-rate=.*|profiler.sampling.counting.sampling-rate=1|' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   
   sed -i 's|^profiler.statdatasender.write.queue.size=.*|profiler.statdatasender.write.queue.size=51200|' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   
}

function runPinpointBasic {
   k=$1
   export BENCHMARK_OPTS=$2
   info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
   echo "Running with $BENCHMARK_OPTS"
   setPinpointConfig
   startPinpointServers
   
   java $DEFAULT_JVM_OPTS $JAVA_OPTS $BENCHMARK_OPTS \
        -cp ../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar \
        moobench.benchmark.BenchmarkMain \
        --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &
   PID=$!
   sleep $WARMUP_TIME
    
   echo "Starting profiling of $PID"
   $ASYNC_PROFILER_HOME/bin/asprof -f "flamegraph_${i}_${RECURSION_DEPTH}_${k}.html" start $PID
    
   wait $PID
   stopPinpointServers
}

# end
