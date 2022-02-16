#!/bin/bash

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

## Clean up raw results
function cleanup-results() {
  (cd $RESULTS_DIR && tar -I xz -cf results.tar.xz raw*)
  rm -f ${RAWFN}*
  [ -f ${DATA_DIR}/nohup.out ] && cp ${DATA_DIR}/nohup.out ${RESULTS_DIR}
  [ -f ${DATA_DIR}/nohup.out ] && > ${DATA_DIR}/nohup.out
}

function checkMoobenchApplication() {
	if [ ! -f "MooBench.jar" ]
	then
		echo "MooBench.jar missing; please build it first using ./gradlew assemble in the main folder"
		exit 1
	fi
}

function getKiekerAgent() {
	echo "Checking whether Kieker is present in $AGENT"
	if [ ! -f $AGENT ]
	then
		# get agent
		export VERSION_PATH=`curl "https://oss.sonatype.org/service/local/repositories/snapshots/content/net/kieker-monitoring/kieker/" | grep '<resourceURI>' | sed 's/ *<resourceURI>//g' | sed 's/<\/resourceURI>//g' | grep '/$'`
		export AGENT_PATH=`curl "${VERSION_PATH}" | grep 'aspectj.jar</resourceURI' | sort | sed 's/ *<resourceURI>//g' | sed 's/<\/resourceURI>//g' | tail -1`
		curl "${AGENT_PATH}" > "${AGENT}"
	fi
}

function getInspectItAgent() {
	if [ ! -d agent ]
	then
		mkdir agent
		cd agent
		wget https://github.com/inspectIT/inspectit-ocelot/releases/download/1.11.1/inspectit-ocelot-agent-1.11.1.jar
		cd ..
	fi
}

function getOpentelemetryAgent() {
	if [ ! -f ${BASEDIR}lib/opentelemetry-javaagent-all.jar ]
	then
		mkdir -p ${BASEDIR}lib
		wget --output-document=${BASEDIR}lib/opentelemetry-javaagent-all.jar \
			https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent-all.jar
	fi
}

function createRLabels() {
	# Create R labels
	LABELS=""
	for I in "${TITLE[@]}" ; do
		title="$I"
		if [ "$LABELS" == "" ] ; then
			LABELS="\"$title\""
		else
			LABELS="${LABELS}, \"$title\""
		fi
	done
	echo $LABELS
}

## Generate Results file
function run-r() {
R --vanilla --silent << EOF
results_fn="${RAWFN}"
outtxt_fn="${RESULTS_DIR}/results-text.txt"
outcsv_fn="${RESULTS_DIR}/results-text.csv"
configs.loop=${NUM_OF_LOOPS}
configs.recursion=${RECURSION_DEPTH}
configs.labels=c($LABELS)
results.count=${TOTAL_NUM_OF_CALLS}
results.skip=${TOTAL_NUM_OF_CALLS}/2
source("${RSCRIPT_PATH}")
EOF
}

function startZipkin {
	if [ ! -d zipkin ] || [ ! -f zipkin/zipkin.jar ]
	then
		mkdir zipkin
		cd zipkin
		curl -sSL https://zipkin.io/quickstart.sh | bash -s
	else
		cd zipkin
	fi
	java -Xmx6g -jar zipkin.jar &> zipkin.txt &
	pid=$!
	sleep 5
	cd ..
}

function periodicallyCurlPrometheus {
	while [ true ]
	do
		echo "Curling for prometheus simulation..."
		curl localhost:8888/metrics 
		sleep 15
	done
}

function startPrometheus {
	periodicallyCurlPrometheus &
	pid=$!
}

function stopBackgroundProcess {
	kill $pid
}

function writeConfiguration() {
	uname -a >${RESULTS_DIR}/configuration.txt
	${JAVABIN}java ${JAVAARGS} -version 2>>${RESULTS_DIR}/configuration.txt
	echo "JAVAARGS: ${JAVAARGS}" >>${RESULTS_DIR}/configuration.txt
	echo "" >>${RESULTS_DIR}/configuration.txt
	echo "Runtime: circa ${TIME} seconds" >>${RESULTS_DIR}/configuration.txt
	echo "" >>${RESULTS_DIR}/configuration.txt
	echo "SLEEPTIME=${SLEEPTIME}" >>${RESULTS_DIR}/configuration.txt
	echo "NUM_OF_LOOPS=${NUM_OF_LOOPS}" >>${RESULTS_DIR}/configuration.txt
	echo "TOTAL_NUM_OF_CALLS=${TOTAL_NUM_OF_CALLS}" >>${RESULTS_DIR}/configuration.txt
	echo "METHODTIME=${METHODTIME}" >>${RESULTS_DIR}/configuration.txt
	echo "THREADS=${THREADS}" >>${RESULTS_DIR}/configuration.txt
	echo "RECURSION_DEPTH=${RECURSION_DEPTH}" >>${RESULTS_DIR}/configuration.txt
	sync
}

function printIntermediaryResults {
   for ((index=0;index<${#TITLE[@]};index+=1)); do
      echo -n "Intermediary results "${TITLE[$index]}" "
      cat $RESULTS_DIR/raw-*-${RECURSION_DEPTH}-${index}.csv | awk -F';' '{print $2}' | getSum
   done
}


FRAMEWORK_NAME=$(basename -- "$BASE_DIR")
RESULTS_DIR="$BASE_DIR/results-$FRAMEWORK_NAME"
RAWFN=$RESULTS_DIR"/raw"

# Initialize all unset parameters
if [ -z $SLEEP_TIME ]; then
	SLEEP_TIME=30           ## 30
fi
if [ -z $NUM_OF_LOOPS ]; then
	NUM_OF_LOOPS=10           ## 10
fi
if [ -z $THREADS ]; then
	THREADS=1              ## 1
fi
if [ -z $RECURSION_DEPTH ]; then
	RECURSION_DEPTH=10      ## 10
fi
if [ -z $TOTAL_NUM_OF_CALLS ]; then
	TOTAL_NUM_OF_CALLS=2000000     ## 2000000
fi
if [ -z $METHOD_TIME ]; then
	METHOD_TIME=0      ## 500000
fi
if [ -z $DEBUG ]; then
	DEBUG=false		## false
fi
