function getSum {
	awk '{sum += $1; square += $1^2} END {print "Average: "sum/NR" Standard Deviation: "sqrt(square / NR - (sum/NR)^2)" Count: "NR}'
}

function getMinMax {
	awk 'NR == 1 {min = max = $1} 
     $1 < min {min = $1} 
     $1 > max {max = $1} 
     END {print "Min ", min, "Max ", max}'
}

function getFileAverages {
	folder=$1
	resultsfolder=$2

	sizes=$(ls | grep results- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		unzip $folder/results-$size.zip
		variants=$(ls $folder | grep raw | awk -F'[-.]' '{print $4}' | sort | uniq)
		for variant in $variants
		do
		        for file in $(ls $1/raw-*-$variant.csv)
		        do
		                fileSize=$(cat $file | wc -l)
		                afterWarmup=$(($fileSize/2))
		                average=$(tail -n $afterWarmup $file | awk -F';' '{print $2}' | getSum | awk '{print $2}')
		                echo $variant";"$size";"$average
		        done
		done >> $resultsfolder/duration_$framework.csv
		
		for variant in $variants
		do
		        for file in $(ls $1/raw-*-$variant.csv)
		        do
		        		minMax=$(awk -F';' '{print $3}' $file | getMinMax)
		        		min=$(echo $minMax | awk '{print $2/1000000}') # RAM in MB
		        		max=$(echo $minMax | awk '{print $4/1000000}')
		        		gcs=$(cat $file | awk -F';' '{sum+=$4} END {print sum}')
		        		echo $variant";"$size";"$min";"$max";"$gcs
		        done
		done >> $resultsfolder/ram_$framework.csv
				
		echo "Written to $resultsfolder/duration_$framework.csv"
		cat $resultsfolder/duration_$framework.csv
		rm $folder/raw*
	done
}

function getDurationEvolution {
	framework=$1
	resultsfolder=$2
	variants=$(cat $resultsfolder/duration_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(cat $resultsfolder/duration_$framework.csv | awk -F';' '{print $2}' | sort -n | uniq)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $resultsfolder/duration_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $3}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $resultsfolder/evolution_$framework.csv
}

function getRAMEvolution {
	framework=$1
	resultsfolder=$2
	variants=$(cat $resultsfolder/ram_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(cat $resultsfolder/duration_$framework.csv | awk -F';' '{print $2}' | sort -n | uniq)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $resultsfolder/ram_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $3}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $resultsfolder/evolution_ram_min_$framework.csv
}

function getAbsoluteRAMEvolution {
	framework=$1
	resultsfolder=$2
	variants=$(cat $resultsfolder/ram_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(cat $resultsfolder/duration_$framework.csv | awk -F';' '{print $2}' | sort -n | uniq)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $resultsfolder/ram_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $4}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $resultsfolder/evolution_ram_max_$framework.csv
}

function getGCEvolution {
	framework=$1
	resultsfolder=$2
	variants=$(cat $resultsfolder/ram_$framework.csv | awk -F';' '{print $1}' | sort | uniq)
	sizes=$(cat $resultsfolder/duration_$framework.csv | awk -F';' '{print $2}' | sort -n | uniq)
	for size in $sizes
	do
		echo -n "$size;"
		for variant in $variants
		do
			cat $resultsfolder/ram_$framework.csv | grep "^$variant;$size;" | awk -F';' '{print $5}' | getSum | awk '{print $2";"$5";"}' | tr -d "\n"
		done
		echo
	done > $resultsfolder/evolution_gc_$framework.csv
}

function getFrameworkEvolutionFolder {
	folder=$1
	framework=$2
	resultsfolder=$3
	if [ ! -d $resultsfolder ]
	then
		mkdir -p $resultsfolder
	fi
	
	if [ ! -f $resultsfolder/duration_$framework.csv ] || [ ! -f $resultsfolder/ram_$framework.csv ]
	then
		cd $folder
	    	pwd
		echo "" > $resultsfolder/duration_$framework.csv
		getFileAverages $1 $resultsfolder
	fi
	
	getDurationEvolution $framework $resultsfolder
	getAbsoluteRAMEvolution $framework $resultsfolder
	getRAMEvolution $framework $resultsfolder
	getGCEvolution $framework $resultsfolder
}

function getFrameworkEvolutionFile {
	folder=$1
	framework=$2
	if [ -d $folder/exp-results-$framework/ ]
	then
		resultsfolder=$start/results_depth
		getFrameworkEvolutionFolder $folder/exp-results-$framework/ $framework $resultsfolder
	fi
	
	if [ -d $folder/parallel-results-$framework/ ]
	then
		resultsfolder=$start/results_threads
		getFrameworkEvolutionFolder $folder/parallel-results-$framework/ $framework $resultsfolder
	fi
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

for framework in Kieker-java OpenTelemetry-java inspectIT-java elasticapm-java Skywalking-java pinpoint-java Scouter-java
do
	echo "Analysing $framework"
	getFrameworkEvolutionFile $1 $framework
done

cd $start
if [ -d $1/exp-results-Kieker-java ]
then
	echo "Plotting depth"
	gnuplot -e "type='depth'" -c plotExponential.plt
fi

if [ -d $1/parallel-results-Kieker-java ]
then
	echo "Plotting threads"
	gnuplot -e "type='threads'" -c plotExponential.plt
fi
