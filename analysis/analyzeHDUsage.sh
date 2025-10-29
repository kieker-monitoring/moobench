
function getHDUsages {
	folder=$1
	resultsfolder=$2

	echo "Writing to $resultsfolder"
	sizes=$(ls | grep output- | awk -F'-' '{print $2}' | tr -d ".zip" | sort -n)
	for size in $sizes
	do
		unzip output-$size.zip
		variants=$(ls . | grep output_ | awk -F'[_.]' '{print $4}' | sort | uniq)
		for variant in $variants
		do
		        for file in $(ls output_*_"$size"_"$variant".txt)
		        do
		        		cat $file | grep "Disk usage" | awk '{print '$size'";"'$variant'";"$3}'
		        done
		done >> $resultsfolder/hdusage_$framework.csv
		rm output_*
	done
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
resultsfolder=$start/results_hd
mkdir -p $resultsfolder
cd $1


for framework in Kieker-java OpenTelemetry-java inspectIT-java elasticapm-java Skywalking-java pinpoint-java
do
	folder=exp-results-$framework
	if [ -d $folder ]
	then
		cd $folder
		echo "" >> $resultsfolder/hdusage_$framework.csv
		getHDUsages $folder $resultsfolder
		cd ..
	fi
done


