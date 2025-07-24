#!/bin/bash

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

source ../labels.sh

export size=10
result="["

if [ -z "$MOOBENCH_CONFIGURATIONS" ]
then
   echo "Error: \$MOOBENCH_CONFIGURATIONS was not defined" 1>&2
   exit 1
fi
   

for variant in $MOOBENCH_CONFIGURATIONS
do
   values=$(
   for file in $(ls raw-*-$size-$variant.csv)
   do
      cat $file | awk -F';' '{print $2}'
   done | getSum)
   value=$(echo $values | awk '{print $2}')
   standardDeviation=$(echo $values | awk '{print $5}')

   configurationName="${TITLE[$variant]}"
   result="$result{\"name\": \"$configurationName\", \"unit\": \"ns\", \"value\": $value, \"range\": $standardDeviation},"
done
withoutLastKomma=${result::-1}

echo "$withoutLastKomma]"
