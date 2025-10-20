function getSum {
	awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

function getFileAverages {
	
	sizes=$(ls | grep results- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		unzip $1/results-$size.zip
		variants=$(ls $1 | grep raw | awk -F'[-.]' '{print $4}' | sort | uniq)
		for variant in $variants
		do
		        for file in $(ls $1/raw-*-$size-$variant.csv)
		        do
		                fileSize=$(cat $file | wc -l)
		                afterWarmup=$(($fileSize/2))
		                average=$(tail -n $afterWarmup $file | awk -F';' '{print $2}' | getSum | awk '{print $2}')
		                echo $variant";"$size";"$average
		        done
		done >> $RESULTFOLDER/duration_$framework.csv
		
		exit 1
		
		for variant in $variants
		do
		        for file in $(ls $1/raw-*-$size-$variant.csv)
		        do
		        		
		        		startValue=$(head -n 1 $file | awk -F';' '{print $3}')
		        		endValue=$(tail -n 1 $file | awk -F';' '{print $3}')
		        		gcs=$(cat $file | awk -F';' '{sum+=$4} END {print sum}')
		        		echo $variant";"$size";"$startValue";"$endValue";"$gcs
		        done
		done >> $RESULTFOLDER/ram_$framework.csv
		
		
		echo "Written to $RESULTFOLDER/duration_$framework.csv"
		cat $RESULTFOLDER/duration_$framework.csv
		rm $1/raw*
	done
}

function getDurationEvolution {
	framework=$1
	variants=$(cat $RESULTFOLDER/duration_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(ls | grep results- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $RESULTFOLDER/duration_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $3}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $RESULTFOLDER/evolution_$framework.csv
}

function getRAMEvolution {
	framework=$1
	variants=$(cat $RESULTFOLDER/ram_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(ls | grep results- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $RESULTFOLDER/ram_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print ($4-$3)/1000000}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $RESULTFOLDER/evolution_ram_$framework.csv
}

function getAbsoluteRAMEvolution {
	framework=$1
	variants=$(cat $RESULTFOLDER/ram_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(ls | grep results- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $RESULTFOLDER/ram_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $4/1000000}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $RESULTFOLDER/evolution_ram_absolute_$framework.csv
}

function getGCEvolution {
	framework=$1
	variants=$(cat $RESULTFOLDER/ram_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(ls | grep results- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $RESULTFOLDER/ram_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $5}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $RESULTFOLDER/evolution_gc_$framework.csv
}

function getFrameworkEvolutionFile {
	folder=$1
	framework=$2
	if [ ! -f $RESULTFOLDER/duration_$framework.csv ] || [ ! -f $RESULTFOLDER/ram_$framework.csv ]
	then
		if [ -d $folder/exp-results-$framework/ ]
		then
			cd $folder/exp-results-$framework
	     	pwd
			echo "" > $RESULTFOLDER/duration_$framework.csv
			getFileAverages $1/exp-results-$framework/
		fi
	fi
	getDurationEvolution $framework
	getAbsoluteRAMEvolution $framework
	getRAMEvolution $framework
	getGCEvolution $framework
}

if [ "$#" -lt 1 ]; then
	echo "Please pass the folder where exp-results-Kieker, exp-results-OpenTelemetry and exp-results-inspectIT are"
	exit 1
fi

if [ ! -d $1 ]; then
	echo "$1 should be a folder, but is not."
	exit 1
fi

start=$(pwd)

RESULTFOLDER=$start/results
if [ ! -d $RESULTFOLDER ]
then
	mkdir -p $RESULTFOLDER
fi

for framework in Kieker-java OpenTelemetry-java inspectIT-java elasticapm-java Skywalking-java pinpoint-java
do
	echo "Analysing $framework"
	getFrameworkEvolutionFile $1 $framework
done

cd $start
gnuplot -c plotExponential.plt
