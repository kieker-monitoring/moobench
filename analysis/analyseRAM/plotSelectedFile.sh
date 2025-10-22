

function summarizeFile {
	file=$1
	awk -F';' -v B="$blocksize" '
	{
	    sum2 += $2
	    sum3 += $3
	    count++

	    if (count == B) {
		   avg2 = sum2 / B
		   avg3 = sum3 / B
		   print avg2 ";" avg3
		   sum2 = sum3 = count = 0
	    }
	}
	END {
	    # Falls am Ende weniger als B Zeilen übrig bleiben, trotzdem ausgeben
	    if (count > 0) {
		   avg2 = sum2 / count
		   avg3 = sum3 / count
		   print $1 ";" avg2 ";" avg3
	    }
	}' "$file" &> selected_file.csv
}

start=$(pwd)

blocksize=1000

mkdir -p graphs

for framework in Kieker-java OpenTelemetry-java inspectIT-java elasticapm-java Skywalking-java pinpoint-java
do
	case "$framework" in
		Kieker-java)
			index=5
			;;
		Skywalking-java | scouter)
            index=1
            ;;
        elasticapm-java)
            index=2
            ;;
        OpenTelemetry-java | inspectIT-java | pinpoint-java)
            index=3
            ;;
		*)
			index=0   # fallback, falls etwas nicht passt
		;;
	esac
	echo "Analysing $framework"
	cd $1/exp-results-$framework
	unzip results-128.zip "raw-10-128-$index.csv"
	ls
	
	summarizeFile raw-10-128-$index.csv
	gnuplot -c $start/plotSingleFile.plt
	
	mv single-file-evolution.pdf $start/graphs/$framework.pdf
done
