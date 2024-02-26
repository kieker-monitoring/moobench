#!/bin/bash

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

start=$(pwd)

if [ $# -gt 0 ]
then
	if [ -d $1 ]
	then
		cd $1
	else
		echo "Folder does not exist: $1"
		exit 1
	fi
else
	echo "Folder should be passed as parameter."
fi

if [ -f unzip.txt ]
then
	rm unzip.txt
fi

for technology in OpenTelemetry-java Kieker-java Kieker-java-javassist Kieker-java-bytebuddy Kieker-java-DiSL Kieker-java-sourceinstrumentation
do
	
	if [ ! -f $technology.csv ]
	then
	
		sizes=$(ls $technology-exp-results | grep ".zip" | tr -d "results-" | tr -d ".zip" | sort -n)
		echo "Sizes for $technology: $sizes"
		for size in $sizes
		do
			echo "Analyzing $size"
			case "$technology" in
				"OpenTelemetry-java") suffix="-3" ;;
				*) suffix="-4" ;;
			esac
			echo "Suffix: $suffix"
			
			unzip $technology-exp-results/results-$size.zip >> unzip.txt
			
			for file in raw-*$suffix.csv
			do
				echo -n $file" "
				TOTAL_NUM_OF_CALLS=$(wc -l $file | awk '{print $1}')
				WARMUP=$(($TOTAL_NUM_OF_CALLS / 4))
				WARMUP_REST=$(($WARMUP-5))
				AFTER_WARMUP=$(($TOTAL_NUM_OF_CALLS / 2))
				tail -n $AFTER_WARMUP $file | awk -F';' '{print $2}' | getSum | awk '{print $2}' | tr "\n" " "
				head -n $WARMUP $file | tail -n $WARMUP_REST | awk -F';' '{print $2}' | getSum | awk '{print $2}'
			done &> $technology"_"$size.csv
			rm raw-*csv
		done
		
		for size in $sizes
		do
			echo -n $size" "
			cat $technology"_"$size.csv | awk '{print $2}' | getSum	| tr "\n" " "
			cat $technology"_"$size.csv | awk '{print $3}' | getSum	
		done | awk '{print $1";"$3";"$6";"$10";"$13}' &> $technology.csv
		sed -i '1 i\#Size;Average (Warmed Up);Standard Deviation (Warmed Up);Average (Warmup);Standard Deviation (Warmup)' $technology.csv
	else
		echo "Skipping $technology since result file is already existing."
	fi
done

gnuplot -c $start/plot.plt 
