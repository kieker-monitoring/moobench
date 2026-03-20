if [ $# -lt 1 ]; then
  echo "Please pass the folder that should be analyzed"
fi

if [[ "$1" = /* ]]; then
  echo "absolute path"
  BASE_DIR=$1
else
  echo "relative path"
  BASE_DIR=$(pwd)/$1
fi

source common-functions.sh

source $1/labels.sh

echo "RESULTS_DIR: ${RESULTS_DIR}"
echo "Rawfn: $RAWFN"

RSCRIPT_PATH=stats.csv.r

# Create R labels
LABELS=$(createRLabels)
run-r
