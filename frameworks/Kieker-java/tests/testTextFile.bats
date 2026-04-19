#!/usr/bin/env bats

setup() {
  load "$BATS_TEST_DIRNAME/../../../test/test_helper/bats-support/load"
  load "$BATS_TEST_DIRNAME/../../../test/test_helper/bats-assert/load"

  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$DIR/../src:$PATH"
}

@test "Check that Kieker creates text files" {
  export MOOBENCH_CONFIGURATIONS="0 3"
  export SLEEP_TIME=0
  export NUM_OF_LOOPS=1
  export TOTAL_NUM_OF_CALLS=100
  export RECURSION_DEPTH=10
  export MORE_PARAMS="--quickstart"

  cd "$BATS_TEST_DIRNAME/.." || exit 1
  rm -rf data/kieker-*

  # We mock rm, so tracing data are not deleted
  rm() {
    if [[ "$*" == *"/kieker-"* ]]; then
      echo "Mock: Not deleting $2" >&3
    else
      command rm "$@"
    fi
  }
  export -f rm

  run ./benchmark.sh
  assert_output --partial '# 1.10.0 No instrumentation'
  assert_output --partial '# 1.10.3 Text file'
  
  [ "$status" -eq 0 ]
  run bash -c "grep '\$1' data/kieker-*/*.dat | wc -l"
  expected=$(( RECURSION_DEPTH * TOTAL_NUM_OF_CALLS ))
  assert_output "$expected"

  unset -f rm
}

@test "Check result value creation" {
  cd "$BATS_TEST_DIRNAME/.." || exit 1
  rm -r results-Kieker-java/

  export SLEEP_TIME=0
  export NUM_OF_LOOPS=1 
  export TOTAL_NUM_OF_CALLS=10 
  export RECURSION_DEPTH=10 
  ./benchmark.sh 

  cd results-Kieker-java/
  count=$(ls *.csv 2>/dev/null | wc -l)
  assert_equal "$count" "0" \
    "0 .csv files should exist after the run, files should only be in the zipped folder"
  unzip results.zip 
  measuredValues=$(cat raw-1-10-* | wc -l) 
  if [ $measuredValues -ne 50 ]; then
    echo "It should be 50 measured values, but was $measuredValues"
    exit 1
  fi
}
