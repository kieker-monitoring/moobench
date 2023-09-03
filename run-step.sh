#!/bin/bash

./frameworks/Kieker-python/benchmark.sh || exit
./frameworks/Kieker-java/benchmark.sh || exit
./frameworks/OpenTelemetry-java/benchmark.sh || exit
./frameworks/inspectIT-java/benchmark.sh || exit

echo "copy"
cp -v frameworks/Kieker-python/results/results.yaml Kieker-python-results.yaml
cp -v frameworks/Kieker-java/results/results.yaml Kieker-java-results.yaml
cp -v frameworks/OpenTelemetry-java/results/results.yaml OpenTelemetry-java-results.yaml
cp -v frameworks/inspectIT-java/results/results.yaml inspectIT-java-results.yaml

# end

