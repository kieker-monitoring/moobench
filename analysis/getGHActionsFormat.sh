#!/bin/bash

source ../../../common-functions.sh

source ../labels.sh

export size=10
result="["

if [ -z "$MOOBENCH_CONFIGURATIONS" ]; then
   echo "Error: \$MOOBENCH_CONFIGURATIONS was not defined" 1>&2
   exit 1
fi

for variant in $MOOBENCH_CONFIGURATIONS; do

   values=$(
    for file in $(ls raw-*-$size-$variant.csv); do
      echo $file
      getStatisticsOfMeasurementFile $file
    done | awk '{print $9}' | getSum
  )

   value=$(echo $values | awk '{print $2}')
   standardDeviation=$(echo $values | awk '{print $5}')

   configurationName="${TITLE[$variant]}"
   result="$result{\"name\": \"$configurationName\", \"unit\": \"ns\", \"value\": $value, \"range\": $standardDeviation},"
done
withoutLastKomma=${result::-1}

echo "$withoutLastKomma]"
