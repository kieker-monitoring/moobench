TITLE[0]="No instrumentation"
TITLE[1]="No logging"
TITLE[2]="Logging"
TITLE[3]="Zipkin"
TITLE[4]="Prometheus"
MACHINE_TYPE=`uname -m`; 
if [ ${MACHINE_TYPE} == 'x86_64' ]
then
	#TITLE[5]="OpenTelemetry Jaeger"
fi
