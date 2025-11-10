export METHOD_TIME=50000
export SLEEP_TIME=0; export MOOBENCH_CONFIGURATIONS="3"; export NUM_OF_LOOPS=1; 
export TOTAL_NUM_OF_CALLS=5000000;
df
echo
echo
export RECURSION_DEPTH=128; ./benchmark.sh
cat results-OpenTelemetry-java/output_* 
mv cassandra_logs.txt cassandra_128.txt
mv zipkin/zipkin.txt zipkin/zipkin_128.txt
df
echo
echo

df
echo
echo
export RECURSION_DEPTH=2; ./benchmark.sh
cat results-OpenTelemetry-java/output_*
