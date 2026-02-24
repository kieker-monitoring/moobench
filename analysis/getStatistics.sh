#!/bin/bash

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

function getConfigurations {
  ls | grep "raw" | awk -F'[-\.]' '{print $4}' | sort | uniq
}

function getValues {
  folder=$1

  if [ -d $folder ] && [ ! -f $folder.csv ]; then
    cd $folder
    pwd
    rm raw*
    unzip results.zip

    configurations=$(getConfigurations)
    echo "Configurations: $configurations"

    for configuration in $configurations; do
      for file in $(ls raw-*-$configuration.csv); do
        fileSize=$(cat $file | wc -l)
        afterWarmup=$(($fileSize / 2))
        average=$(tail -n $afterWarmup $file | awk -F';' '{print $2}' | getSum | awk '{print $2}')
        echo $configuration" "$average
      done
    done &> ../$folder.csv
    rm raw*
    cd ..
  fi
}

start=$(pwd)

cd $1
for file in results-*; do
  echo "Folder: $file"
  getValues $file
  cd $1
done

for file in *.csv; do
  framework=$(echo "${file#results-}" | sed 's/\.csv$//')
  echo -n "  \multicolumn{3}{|c|}{\textbf{$framework}} \\\\ "
  source $start/../frameworks/$framework/labels.sh
  configurations=$(cat $file | awk '{print $1}' | sort | uniq)
  for configuration in $configurations; do
    #echo -n $configuration" "
    echo " \\hdashline"
    echo -n "  ${TITLE[$configuration]} & "
    cat $file | grep "^$configuration" | awk '{print $2}' | getSum | awk '{printf " %.2f & %.2f \\\\ ", $2, $5}'
  done
  echo " \\hline"
done
