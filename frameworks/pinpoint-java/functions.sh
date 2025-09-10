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

function startHBaseAndKafkaContainers {
	docker run -d \
		--name hbase \
		--hostname hbase \
		--net=host \
		--entrypoint /bin/sh \
		openeuler/hbase:2.6.3-oe2403sp1 \
		-c "
# hostname-Befehl ad-hoc definieren
hostname() { cat /etc/hostname; }
export -f hostname

# embedded ZK auf 0.0.0.0 setzen
sed -i '/<configuration>/a <property><name>hbase.zookeeper.property.clientPortAddress</name><value>0.0.0.0</value></property>' /usr/local/hbase/conf/hbase-site.xml

sed -i '/<configuration>/a <property><name>hbase.master.hostname</name><value>localhost</value></property>' /usr/local/hbase/conf/hbase-site.xml
sed -i '/<configuration>/a <property><name>hbase.master.port</name><value>16000</value></property>' /usr/local/hbase/conf/hbase-site.xml


# HBase starten und Logs anhängen
/usr/local/hbase/bin/start-hbase.sh && tail -F /usr/local/hbase/logs/*
"
	docker run -d \
		--name kafka \
		--net=host \
		-e KAFKA_NODE_ID=1 \
		-e KAFKA_PROCESS_ROLES=broker,controller \
		-e KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
		-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
		-e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
		-e KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT \
		-e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
		-e CLUSTER_ID=abcdefghijklmnopqrstuv \
		confluentinc/cp-kafka:7.6.0
}

function startHBase() {
	echo "Starting HBase openeuler/hbase:2.6.3-oe2403sp1"
   
	if [ ! -f hbase-create.hbase ]
	then
		wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/refs/heads/master/hbase/scripts/hbase-create.hbase
	fi
	
	echo "Warte auf HBase-Master ..."
	docker logs -f hbase 2>&1 | grep -m1 "Master has completed initialization"
	echo "HBase-Master ist bereit."
     
	echo "Initialising hbase tables - log goes to hbase-creation-log.txt"
	docker cp hbase-create.hbase hbase:/tmp/hbase-create.hbase
	docker exec hbase hbase shell /tmp/hbase-create.hbase &> hbase-creation-log.txt
	echo
	echo
}

function stopHBase(){
	echo "Stopping HBase $HBASE_VERSION"
	docker rm -f hbase
}

export KAFKA_VERSION=4.1.0
export SCALA_VERSION=2.13
function startKafka() {
	echo "Starting Kafka"  
	docker exec kafka kafka-topics \
		--create \
		--if-not-exists \
		--topic inspector-stat-agent-00 \
		--bootstrap-server localhost:9092 \
		--replication-factor 1 \
		--partitions 1
	docker exec kafka kafka-topics \
		--create \
		--if-not-exists \
		--topic inspector-stat-agent-01 \
		--bootstrap-server localhost:9092 \
		--replication-factor 1 \
		--partitions 1
 
	docker exec kafka kafka-topics \
		--create \
		--if-not-exists \
		--topic inspector-stat-app \
		--bootstrap-server localhost:9092 \
		--replication-factor 1 \
		--partitions 1
		
	echo
	echo
}

function stopKafka {
  docker rm -f kafka
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

export PINOT_VERSION=1.4.0
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

   if [ ! -f pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar ]
   then
      wget https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-collector-starter/${PINPOINT_VERSION}/pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar
   fi
   
   RATE_LIMIT=100000
   REFILL=20000
   
   java --add-opens=java.base/java.nio=ALL-UNNAMED -Dpinpoint.zookeeper.address=localhost \
   	-Dcollector.receiver.grpc.stat.stream.flow-control.rate-limit.capacity=$RATE_LIMIT \
   	-Dcollector.receiver.grpc.stat.stream.flow-control.rate-limit.refill-greedy=$REFILL \
   	-Dcollector.receiver.grpc.span.stream.flow-control.rate-limit.capacity=$RATE_LIMIT \
   	-Dcollector.receiver.grpc.span.stream.flow-control.rate-limit.refill-greedy=$REFILL \
   	-Dcollector.receiver.grpc.agent.stream.flow-control.rate-limit.capacity=$RATE_LIMIT \
   	-Dcollector.receiver.grpc.agent.stream.flow-control.rate-limit.refill-greedy=$REFILL \
   	-Dmanagement.otlp.metrics.export.enabled=false \
   	-Dcollector.kafka.enabled=false \
   	-Dpinpoint.modules.realtime.enabled=false \
   	-Dpinpoint.modules.collector.inspector.enabled=false \
   	-Dpinpoint.collector.type=BASIC \
   	-Dpinpoint.metric.kafka.bootstrap.servers=localhost:9092 \
   	-jar pinpoint-collector-starter-${PINPOINT_VERSION}-exec.jar &> ${BASE_DIR}/logs/collector.log &
   
   waitForStartup ${BASE_DIR}/logs/collector.log "Started PinpointCollectorStarter in"
   
   
   if [ ! -f pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar ]
   then
      wget https://repo1.maven.org/maven2/com/navercorp/pinpoint/pinpoint-web-starter/${PINPOINT_VERSION}/pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar
   fi
   
   java --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED -Dpinpoint.zookeeper.address=localhost -Dpinpoint.modules.realtime.enabled=false -jar pinpoint-web-starter-${PINPOINT_VERSION}-exec.jar &> ${BASE_DIR}/logs/web-starter.log &
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

	# Containers should be started first and afterwards filled with data
	startHBaseAndKafkaContainers
	startHBase
	startKafka
	
	startPinot
	
	docker run -d \
		--name pinpoint-redis \
		-p 6379:6379 \
		redis:7-alpine
   
	startCollectorAndWeb
	
	
}

function stopPinpointServers {
	stopCollectorAndWeb
	stopKafka
	stopPinot
	stopHBase
   
	docker rm -f pinpoint-redis
   
	# No clue which tool creates these, but they are created...
	rm /tmp/tomcat* -r
}

function setPinpointConfig {
   sed -i 's/DEBUG/INFO/g' pinpoint/pinpoint-agent-${PINPOINT_VERSION}/log4j2-agent.xml
   
   CONFIGFILE=pinpoint/pinpoint-agent-${PINPOINT_VERSION}/profiles/release/pinpoint.config
   sed -i '/profiler.entrypoint/a profiler.transport.grpc.span.sender.executor.queue.size=100000' $CONFIGFILE
   sed -i '/profiler.entrypoint/a profiler.pinpoint.base-package=moobench.application' $CONFIGFILE
   sed -i 's|^profiler.entrypoint=.*|profiler.entrypoint=moobench.application.MonitoredClassSimple.monitoredMethod|' $CONFIGFILE
   sed -i 's|^profiler.include=.*|profiler.include=moobench.application*|' $CONFIGFILE
   sed -i 's|^profiler.sampling.counting.sampling-rate=.*|profiler.sampling.counting.sampling-rate=1|' $CONFIGFILE
   
   sed -i 's|^profiler.statdatasender.write.queue.size=.*|profiler.statdatasender.write.queue.size=51200|' $CONFIGFILE
   
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
    $ASYNC_PROFILER_HOME/bin/asprof \
        -o collapsed \
        -f "flamegraph_${i}_${RECURSION_DEPTH}_${k}.collapsed" \
        start $PID
    
   wait $PID
   stopPinpointServers
}

# end
