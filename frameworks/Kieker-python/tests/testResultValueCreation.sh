#!/usr/bin/env bats

setup() {
  load "$BATS_TEST_DIRNAME/../../../test/test_helper/bats-support/load"
  load "$BATS_TEST_DIRNAME/../../../test/test_helper/bats-assert/load"

  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$DIR/../src:$PATH"
}

@test "Check result value creation" {
  cd "$BATS_TEST_DIRNAME/.." || exit 1
  rm -rf results-Kieker-python/

  export SLEEP_TIME=0
  export NUM_OF_LOOPS=1 
  export TOTAL_NUM_OF_CALLS=10 
  export RECURSION_DEPTH=10 
  ./measure.sh 

  cd results-Kieker-python/
  count=$(ls *.csv 2>/dev/null | wc -l)
  assert_equal "$count" "0" \
    "0 .csv files should exist after the run, files should only be in the zipped folder"
  unzip results.zip 
  measuredValues=$(cat raw-1-10-* | wc -l) 
  if [ $measuredValues -ne 90 ]; then
    echo "It should be 90 measured values, but was $measuredValues"
    exit 1
  fi
}

