source ../common-functions.sh

for file in $(ls results_depth | grep evolution_ | grep -v "_gc_" | grep -v "_ram_"); do
  framework=$(echo $file | awk -F"_" '{print $2}' | sed 's/\.csv//')
  index=$(getDefaultConfiguration $framework)
  meanIndex=$(($index * 2))
  stdDevIndex=$(($meanIndex + 1))
  echo $framework" "$meanIndex

  #awk -F ";" '{print $'$stdDevIndex'/$'$meanIndex'}' results_depth/$file | awk '{sum+=$1} END {print sum/NR}'

  awk -F ";" '{print $1" "$'$meanIndex'}' results_depth/$file &> $framework.csv
done
