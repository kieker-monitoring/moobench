function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

variants=$(ls $1 | grep raw | awk -F'[-.]' '{print $4}' | sort | uniq)
for size in 2 4 8 16 32 64 128; do
  for variant in $variants; do
    allExecutions=$(cat $1/raw-*-$size-$variant.csv | wc -l)
    for file in $(ls $1/raw-*-$size-$variant.csv); do
      fileSize=$(cat $file | wc -l)
      afterWarmup=$(($fileSize / 2))
      average=$(tail -n $afterWarmup $file | awk -F';' '{print $2}' | getSum | awk '{print $2}')
      echo $variant";"$size";"$average
    done
  done
done
