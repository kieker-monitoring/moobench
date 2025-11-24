TITLE[0]="No instrumentation"
TITLE[1]="No logging"
TITLE[2]="Logging"
TITLE[3]="Zipkin"
MACHINE_TYPE=`uname -m`; 
if [ ${MACHINE_TYPE} == 'x86_64' ]
then
	TITLE[4]="Prometheus"
	#TITLE[5]="OpenTelemetry Jaeger"
fi
TITLE[6]="Zipkin+Cassandra"
