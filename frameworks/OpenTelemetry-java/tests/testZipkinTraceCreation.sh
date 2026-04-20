#!/usr/bin/env bats

setup() {
  load "$BATS_TEST_DIRNAME/../../../test/test_helper/bats-support/load"
  load "$BATS_TEST_DIRNAME/../../../test/test_helper/bats-assert/load"

  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$DIR/../src:$PATH"
}

@test "Check Zipkin that OpenTelemetry-java created traces" {
  cd "$BATS_TEST_DIRNAME/.." || exit 1
  rm -rf results-OpenTelemetry-java/

  # We mock stopBackgroundProcess, so tracing data are not deleted
  kill() {
    if [[ "$*" == *"-9"* ]] || ps -p "$1" -o comm= | grep -q "java"; then
       echo "Mock: Prevented killing Zipkin (pid $1)" >&3
       return 0
    fi
    command kill "$@"
  }
  export -f kill

  export SLEEP_TIME=0
  export NUM_OF_LOOPS=1 
  export TOTAL_NUM_OF_CALLS=4 
  export RECURSION_DEPTH=10 
  export MOOBENCH_CONFIGURATIONS="0 3"
  export MORE_PARAMS="--quickstart"
  ./benchmark.sh 
  unset -f kill

  ps -aux | grep zipkin
  json=$(curl -s "http://localhost:9411/api/v2/traces?serviceName=moobench&lookback=86400000&limit=1000" | jq)
  traceCount=$(echo "$json" | jq '. | length')
  if [ $traceCount -ne 4 ]; then
    echo "It should be 4 traces, but was $traceCount"
    echo $json
    zipkinPID=$(ps -aux | grep zipkin | awk '{print $2}')
    kill $zipkinPID
    exit 1
  fi

  zipkinPID=$(ps -aux | grep zipkin | awk '{print $2}')
  kill $zipkinPID

  cd results-OpenTelemetry-java/
  count=$(ls *.csv 2>/dev/null | wc -l)
  assert_equal "$count" "0" \
    "0 .csv files should exist after the run, files should only be in the zipped folder"
  unzip results.zip 
  measuredValues=$(cat raw-1-10-* | wc -l) 
  if [ $measuredValues -ne 8 ]; then
    echo "It should be 8 measured values, but was $measuredValues"
    #exit 1
  fi 
}
