set encoding iso_8859_1
set terminal pdf size 8,5

set datafile separator ";"

resultsfolder='results_'.type
system("mkdir -p ".resultsfolder."/graphs")


set out resultsfolder.'/graphs/Kieker-java.pdf'

set title 'Kieker-java Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration ns'

set key right center

kiekerFile=resultsfolder.'/evolution_Kieker-java.csv'
plot kiekerFile u 1:2 w linespoint lc "red" title 'Baseline', \
	kiekerFile u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     kiekerFile u 1:4 w linespoint lc "yellow" title 'Deactivated Probe', \
	kiekerFile u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     kiekerFile u 1:8 w linespoint lc "red" title 'Logging (Binary)', \
	kiekerFile u 1:($8-$9):($8+$9) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     kiekerFile u 1:10 w linespoint lc "blue" title 'TCP', \
     kiekerFile u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5
#     'results/evolution_Kieker-java.csv' u 1:8 w linespoint lc "green" title 'Logging (Text)', \
#	'results/evolution_Kieker-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
# Activate this, if text logging should be displayed (very big, so disabled by default)	
	
unset output

set out resultsfolder.'/graphs/OpenTelemetry-java.pdf'

set title 'OpenTelemetry-java Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration ns'

set key right center
	
otelFile=resultsfolder.'/evolution_OpenTelemetry-java.csv'
plot otelFile u 1:2 w linespoint lc "red" title 'Baseline', \
	otelFile u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     otelFile u 1:4 w linespoint lc "yellow" title 'No Logging', \
	otelFile u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     otelFile u 1:6 w linespoint lc "red" title 'Zipkin', \
	otelFile u 1:($6-$7):($6+$7) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     otelFile u 1:8 w linespoint lc "blue" title 'Prometheus', \
     otelFile u 1:($8-$9):($8+$9) w filledcurves lc "blue" notitle fs transparent solid 0.5

#    'evolution_OpenTelemetry-java.csv' u 1:6 w linespoint lc "green" title 'Logging (Text)', \
#	'evolution_OpenTelemetry-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc "green" notitle fs transparent solid 0.5, \
# Activate this, if text logging should be displayed (very big, so disabled by default)	
	
unset output

set out resultsfolder.'/graphs/inspectIT.pdf'

set title 'inspectIT Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration ns'

set key right center
	
inspectitFile=resultsfolder.'/evolution_OpenTelemetry-java.csv'
plot inspectitFile u 1:2 w linespoint lc "red" title 'Baseline', \
	inspectitFile u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     inspectitFile u 1:4 w linespoint lc "yellow" title 'No Logging', \
	inspectitFile u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     inspectitFile u 1:6 w linespoint lc "red" title 'Zipkin', \
	inspectitFile u 1:($6-$7):($6+$7) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     inspectitFile u 1:8 w linespoint lc "blue" title 'Prometheus', \
     inspectitFile u 1:($8-$9):($8+$9) w filledcurves lc "blue" notitle fs transparent solid 0.5

	
unset output

set terminal pdf size 6,3

set out resultsfolder.'/graphs/scalability_overview.pdf'

set title 'Overview of Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration ns'

set key left top
	
plot resultsfolder.'/evolution_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	resultsfolder.'/evolution_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     resultsfolder.'/evolution_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	resultsfolder.'/evolution_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	resultsfolder.'/evolution_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	resultsfolder.'/evolution_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	resultsfolder.'/evolution_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	resultsfolder.'/evolution_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_Scouter-java.csv' u 1:4 w linespoint lc "purple" title 'Scouter', \
	resultsfolder.'/evolution_Scouter-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "purple" notitle fs transparent solid 0.5

	
unset output


set out resultsfolder.'/graphs/overview_OpenTelemetry-java.pdf'

set title 'Overview of Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration ns'

set key left top
	
plot resultsfolder.'/evolution_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	resultsfolder.'/evolution_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_OpenTelemetry-java.csv' u 1:4 w linespoint lc "blue" title 'OpenTelemetry-java (No Logging)', \
	resultsfolder.'/evolution_OpenTelemetry-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	resultsfolder.'/evolution_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry-java (Zipkin)', \
	resultsfolder.'/evolution_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5

	
unset output


set out resultsfolder.'/graphs/ram_max_overview.pdf'

set title 'RAM Maximum Usage'

set xlabel 'Call Tree Depth'
set ylabel 'RAM / MB'

set key left top
	
plot resultsfolder.'/evolution_ram_max_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	resultsfolder.'/evolution_ram_max_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_max_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     resultsfolder.'/evolution_ram_max_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_max_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	resultsfolder.'/evolution_ram_max_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_max_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	resultsfolder.'/evolution_ram_max_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_max_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	resultsfolder.'/evolution_ram_max_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_ram_max_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	resultsfolder.'/evolution_ram_max_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_ram_max_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	resultsfolder.'/evolution_ram_max_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5

	
unset output

set out resultsfolder.'/graphs/ram_min_overview.pdf'

set title 'RAM Usage Minimum'

set xlabel 'Call Tree Depth'
set ylabel 'RAM / MB'

set key left top
	
plot resultsfolder.'/evolution_ram_min_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	resultsfolder.'/evolution_ram_min_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_min_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     resultsfolder.'/evolution_ram_min_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_min_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	resultsfolder.'/evolution_ram_min_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_min_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	resultsfolder.'/evolution_ram_min_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_ram_min_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	resultsfolder.'/evolution_ram_min_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_ram_min_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	resultsfolder.'/evolution_ram_min_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_ram_min_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	resultsfolder.'/evolution_ram_min_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5

	
unset output

set out resultsfolder.'/graphs/gc_overview.pdf'

set title 'GC Count'

set xlabel 'Call Tree Depth'
set ylabel 'GC Count'

set key left top
	
plot resultsfolder.'/evolution_gc_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	resultsfolder.'/evolution_gc_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_gc_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     resultsfolder.'/evolution_gc_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_gc_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	resultsfolder.'/evolution_gc_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_gc_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	resultsfolder.'/evolution_gc_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     resultsfolder.'/evolution_gc_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	resultsfolder.'/evolution_gc_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_gc_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	resultsfolder.'/evolution_gc_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	resultsfolder.'/evolution_gc_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	resultsfolder.'/evolution_gc_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5

	
unset output
