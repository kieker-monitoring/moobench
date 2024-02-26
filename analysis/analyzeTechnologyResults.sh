#!/bin/bash

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

echo "Folder: "$(pwd)

function getSum {
  awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

function createCSVs {
	find . -name "*csv" -delete
	unzip results.zip &> unzip.txt
	
	case "$technology" in
		"OpenTelemetry-java") suffix="-3" ;;
		*) suffix="-4" ;;
	esac
	
	for file in raw-*$suffix.csv
	do
		TOTAL_NUM_OF_CALLS=$(wc -l $file | awk '{print $1}')
		WARMUP=$(($TOTAL_NUM_OF_CALLS / 4))
		WARMUP_REST=$(($WARMUP-5))
		AFTER_WARMUP=$(($TOTAL_NUM_OF_CALLS / 2))
		tail -n $AFTER_WARMUP $file | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}' | tr "\n" " "
		head -n $WARMUP $file | tail -n $WARMUP_REST | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}'
	done &> $technology.csv
	
	for file in raw-*1.csv
	do
		TOTAL_NUM_OF_CALLS=$(wc -l $file | awk '{print $1}')
		WARMUP=$(($TOTAL_NUM_OF_CALLS / 4))
		WARMUP_REST=$(($WARMUP-5))
		AFTER_WARMUP=$(($TOTAL_NUM_OF_CALLS / 2))
		tail -n $AFTER_WARMUP $file | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}' | tr "\n" " "
		head -n $WARMUP $file | tail -n $WARMUP_REST | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}'
	done &> $technology"_onlyinst".csv
	
	if [ "$technology" != "OpenTelemetry-java" ]
	then
		files=$(ls raw-*2.csv)
		if [ "$files" != "0" ]
		then
			for file in raw-*2.csv
			do
				TOTAL_NUM_OF_CALLS=$(wc -l $file | awk '{print $1}')
				WARMUP=$(($TOTAL_NUM_OF_CALLS / 4))
				WARMUP_REST=$(($WARMUP-5))
				AFTER_WARMUP=$(($TOTAL_NUM_OF_CALLS / 2))
				tail -n $AFTER_WARMUP $file | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}' | tr "\n" " "
				head -n $WARMUP $file | tail -n $WARMUP_REST | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}'
			done &> $technology"_deactivated".csv
		fi
	fi
	
	for file in raw-*0.csv
	do
		TOTAL_NUM_OF_CALLS=$(wc -l $file | awk '{print $1}')
		WARMUP=$(($TOTAL_NUM_OF_CALLS / 4))
		WARMUP_REST=$(($WARMUP-5))
		AFTER_WARMUP=$(($TOTAL_NUM_OF_CALLS / 2))
		tail -n $AFTER_WARMUP $file | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}' | tr "\n" " "
		head -n $WARMUP $file | tail -n $WARMUP_REST | awk -F';' '{print $2}' | getSum | awk '{print $2/1000}'
	done &> $technology"_baseline".csv
	
	rm raw-*csv
	
	echo "Moving"
	mv "$technology"*csv ..
}

function summarizyTechnology {
	technology=$1
	echo -n "$technology "
	cat $technology"_baseline".csv | getSum | awk '{print sprintf("%.2f", $2)" & "sprintf("%.2f", $5)}'
	echo -n "(deactivated) & "
	cat $technology"_onlyinst".csv | getSum | awk '{print sprintf("%.2f", $2)" & "sprintf("%.2f", $5)}'
	if [ ! $technology = "OpenTelemetry-java" ]
	then
		echo -n "(nologging) & "
		cat $technology"_deactivated".csv | getSum | awk '{print sprintf("%.2f", $2)" & "sprintf("%.2f", $5)}'
	fi
	echo -n "(full) & "
	cat $technology.csv | getSum | awk '{print sprintf("%.2f", $2)" & "sprintf("%.2f", $5)}'
	avgAfterWarmup=$(cat $technology.csv | getSum | awk '{print $2}')
	avgBeforeWarmup=$(cat $technology.csv | awk '{print $2}' | getSum | awk '{print $2}')
	if [ $(awk -v n1=$avgAfterWarmup -v n2=$avgBeforeWarmup 'BEGIN {if (n1>n2) {print "1";}}') ]
	then
		echo "Warning: After before warmup $avgBeforeWarmup was lower than average after warmup $avgAfterWarmup"
	fi
}

if [ -f unzip.txt ]
then
	rm unzip.txt
fi

technologies=$(ls | grep "results-" | cut -c 9-)

for technology in $technologies
do
	echo "Analyzing: $technology"
	
	if [ -d results-$technology ]
	then
		if [ ! -f $technology.csv ]
		then
			echo "Unzipping and analysing"
			cd results-$technology
			
			if [ -f results.zip ]
			then
				echo $(createCSVs)
			else
				echo "File missing: $technology"
			fi
			
			cd ..
		fi
		
		summarizyTechnology $technology
	fi
done

