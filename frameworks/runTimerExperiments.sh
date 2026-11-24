function runNormal {
        cp skywalking-agent-9.6-SNAPSHOT.jar skywalking-agent/skywalking-agent.jar
        export MOOBENCH_CONFIGURATIONS="0 1"; ./measure.sh
        mv results-Skywalking-java results-regular
}

function runPatched {
        cp skywalking-agent-9.6-PATCHED.jar skywalking-agent/skywalking-agent.jar
        export MOOBENCH_CONFIGURATIONS="0 1"; ./measure.sh
        mv results-Skywalking-java results-patched
}

if [[ "$1" == "Kieker" ]]; then
	cd Kieker-java
	export MOOBENCH_CONFIGURATIONS="0 4 5 6 7 8"
	./measure.sh
	mv results-Kieker-java results-default
	
	export MOOBENCH_CONFIGURATIONS="0 4 5 6 7 8"
	./benchmarkScaling.sh Kieker-java DEPTH
fi

if [[ $1 == "Skywalking" ]]; then
	export MOOBENCH_CONFIGURATIONS="0 1"

	cd Skywalking-java
	runNormal
	runPatched

	cp skywalking-agent-9.6-SNAPSHOT.jar skywalking-agent/skywalking-agent.jar
	./measureScaling.sh Skywalking-java DEPTH
	mv Skywalking-java/exp-results-Skywalking-java Skywalking-java/exp-results-regular

	cp skywalking-agent-9.6-PATCHED.jar skywalking-agent/skywalking-agent.jar
	./measureScaling.sh Skywalking-java DEPTH
	mv exp-results-Skywalking-java exp-results-patched
fi
