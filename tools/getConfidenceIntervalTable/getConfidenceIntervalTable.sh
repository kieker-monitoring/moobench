#!/bin/bash

## Generate Results file
function run-r() {
	R --vanilla --silent <<EOF
results_fn="${RAWFN}"
outtxt_fn="${RESULTS_DIR}/results-text.txt"
outcsv_fn="${RESULTS_DIR}/results-text.csv"
configs.loop=${NUM_OF_LOOPS}
configs.recursion=${RECURSION_DEPTH}
configs.labels=c($LABELS)
results.count=${TOTAL_NUM_OF_CALLS}
results.skip=${TOTAL_NUM_OF_CALLS}/2
source("${RSCRIPT_PATH}")
EOF
}

function createVariantsString {
	local LABELS=""
	local variants=$(ls ${RESULTS_DIR} | grep ".csv" | awk -F'[.-]' '{print $4}' | sort | uniq | sed '/^[[:space:]]*$/d')
	for variant in $variants; do
		if [ -z "$LABELS" ]; then
			LABELS="\"$variant\""
		else
			LABELS="$LABELS, \"$variant\""
		fi
	done
	echo $LABELS
}

function createLatexTable {
	cat ${RESULTS_DIR}/results-text.txt | tail -n 8 >transposeMe.csv
	awk '
	{ 
	    for (i=1; i<=NF; i++)  {
		a[NR,i] = $i
	    }
	}
	NF>p { p = NF }
	END {    
	    for(j=1; j<=p; j++) {
		str=a[1,j]
		for(i=2; i<=NR; i++){
		    str=str" "a[i,j];
		}
		print str
	    }
	}' transposeMe.csv >transposed.csv

	cat transposed.csv | awk '{print "["$1-$3";"$1+$3"] & "$2}'
}

if [ "$#" -lt 1 ]; then
	echo "Please pass folder with MooBench CSV files for analysis!"
	exit 1
fi

RESULTS_DIR=$1

RAWFN=${RESULTS_DIR}/raw
NUM_OF_LOOPS=10
RECURSION_DEPTH=10
TOTAL_NUM_OF_CALLS=2000000
LABELS=$(createVariantsString)

RSCRIPT_PATH=$MOOBENCH_HOME/frameworks/Kieker/scripts/stats.csv.r

run-r

createLatexTable
