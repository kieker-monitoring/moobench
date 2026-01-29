function executeBenchmark() {
   for index in $MOOBENCH_CONFIGURATIONS
   do
      case $index in
         0) runNoInstrumentation 0 ;;
         1) runeBPFTracing 1 ;;
         2) runeBPFtoBinary 2 ;;
      esac
      
      cleanup
   done
}

function runNoInstrumentation {
    # No instrumentation
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} ${TITLE[$k]}"
    export BENCHMARK_OPTS="${JAVA_ARGS_NOINSTR}"
    "${MOOBENCH_BIN}" --output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
        --total-calls "${TOTAL_NUM_OF_CALLS}" \
        --method-time "${METHOD_TIME}" \
        --total-threads "${THREADS}" \
        --recursion-depth "${RECURSION_DEPTH}" \
        ${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt"
}

function runeBPFtoText {
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    
    CLASSPATH="../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar:../../benchmark/lib/logback-classic-1.5.11.jar:../../benchmark/lib/logback-classic-1.5.18.jar:../../benchmark/lib/logback-core-1.5.11.jar:../../benchmark/lib/logback-core-1.5.18.jar:../../benchmark/lib/slf4j-api-2.0.15.jar:../../benchmark/lib/slf4j-api-2.0.17.jar"
    
    java -XX:+DTraceMethodProbes -cp $CLASSPATH moobench.benchmark.BenchmarkMain \
    		--quickstart \
		--output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
		--total-calls "${TOTAL_NUM_OF_CALLS}" \
		--method-time "${METHOD_TIME}" \
		--total-threads "${THREADS}" \
		--recursion-depth "${RECURSION_DEPTH}" \
    		${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt" &
        
     JAVA_PID=$!
     
     sleep 1
     
     echo "Attaching to $JAVA_PID"
     sudo bpftrace -p $JAVA_PID monitor.bt -o trace.log
     
     sleep 5
     rm trace.log
}

function runeBPFtoBinary {
    k=$1
    info " # ${i}.$RECURSION_DEPTH.${k} "${TITLE[$k]}
    
	if [ ! -f monitor_binary ]
	then
		clang -g -O2 -target bpf -D__TARGET_ARCH_x86 -I/usr/include/x86_64-linux-gnu -c monitorToRingbuffer.bpf.c -o monitor.bpf.o
		bpftool gen skeleton monitor.bpf.o > monitor.skel.h
		gcc -g -O2 -Wall monitor.c -lbpf -lelf -lz -o monitor_binary
	fi
    
    CLASSPATH="../../benchmark/lib/benchmark.jar:../../benchmark/lib/jcommander-1.72.jar:../../benchmark/lib/logback-classic-1.5.11.jar:../../benchmark/lib/logback-classic-1.5.18.jar:../../benchmark/lib/logback-core-1.5.11.jar:../../benchmark/lib/logback-core-1.5.18.jar:../../benchmark/lib/slf4j-api-2.0.15.jar:../../benchmark/lib/slf4j-api-2.0.17.jar"
    
    java -XX:+DTraceMethodProbes -cp $CLASSPATH moobench.benchmark.BenchmarkMain \
    		--quickstart \
		--output-filename "${RAWFN}-${i}-$RECURSION_DEPTH-${k}.csv" \
		--total-calls "${TOTAL_NUM_OF_CALLS}" \
		--method-time "${METHOD_TIME}" \
		--total-threads "${THREADS}" \
		--recursion-depth "${RECURSION_DEPTH}" \
    		${MORE_PARAMS} &> "${RESULTS_DIR}/output_${i}_${RECURSION_DEPTH}_${k}.txt" &
        
     JAVA_PID=$!
     
     sleep 1
     
     echo "Attaching to $JAVA_PID"
	sudo ./monitor_binary $JAVA_PID
     
     sleep 5
     rm trace.log
}
