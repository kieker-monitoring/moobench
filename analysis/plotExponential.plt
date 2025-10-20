set encoding iso_8859_1
set terminal pdf size 8,5

set datafile separator ";"

set out 'results/Kieker-java.pdf'

set title 'Kieker-java Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'

set key right center
	
plot 'results/evolution_Kieker-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_Kieker-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_Kieker-java.csv' u 1:4 w linespoint lc "yellow" title 'Deactivated Probe', \
	'results/evolution_Kieker-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     'results/evolution_Kieker-java.csv' u 1:8 w linespoint lc "red" title 'Logging (Binary)', \
	'results/evolution_Kieker-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'TCP', \
     'results/evolution_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5
#     'results/evolution_Kieker-java.csv' u 1:8 w linespoint lc "green" title 'Logging (Text)', \
#	'results/evolution_Kieker-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
# Activate this, if text logging should be displayed (very big, so disabled by default)	
	
unset output

set out 'results/OpenTelemetry-java.pdf'

set title 'OpenTelemetry-java Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'

set key right center
	
plot 'results/evolution_OpenTelemetry-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_OpenTelemetry-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_OpenTelemetry-java.csv' u 1:4 w linespoint lc "yellow" title 'No Logging', \
	'results/evolution_OpenTelemetry-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     'results/evolution_OpenTelemetry-java.csv' u 1:6 w linespoint lc "red" title 'Zipkin', \
	'results/evolution_OpenTelemetry-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_OpenTelemetry-java.csv' u 1:8 w linespoint lc "blue" title 'Prometheus', \
     'results/evolution_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "blue" notitle fs transparent solid 0.5

#    'evolution_OpenTelemetry-java.csv' u 1:6 w linespoint lc "green" title 'Logging (Text)', \
#	'evolution_OpenTelemetry-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc "green" notitle fs transparent solid 0.5, \
# Activate this, if text logging should be displayed (very big, so disabled by default)	
	
unset output

set out 'results/inspectIT.pdf'

set title 'inspectIT Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'

set key right center
	
plot 'results/evolution_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_inspectIT-java.csv' u 1:4 w linespoint lc "yellow" title 'No Logging', \
	'results/evolution_inspectIT-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     'results/evolution_inspectIT-java.csv' u 1:6 w linespoint lc "red" title 'Zipkin', \
	'results/evolution_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_inspectIT-java.csv' u 1:8 w linespoint lc "blue" title 'Prometheus', \
     'results/evolution_inspectIT-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "blue" notitle fs transparent solid 0.5

	
unset output

set terminal pdf size 6,3

set out 'results/scalability_overview.pdf'

set title 'Overview of Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'

set key left top
	
plot 'results/evolution_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     'results/evolution_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'results/evolution_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	'results/evolution_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     'results/evolution_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	'results/evolution_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     'results/evolution_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	'results/evolution_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	'results/evolution_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	'results/evolution_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	'results/evolution_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	'results/evolution_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5
#	'results/evolution_Scouter-java.csv' u 1:4 w linespoint lc "purple" title 'Scouter', \
#	'results/evolution_Scouter-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "purple" notitle fs transparent solid 0.5, \

	
unset output


set out 'results/overview_OpenTelemetry-java.pdf'

set title 'Overview of Method Execution Durations'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'

set key left top
	
plot 'results/evolution_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_OpenTelemetry-java.csv' u 1:4 w linespoint lc "blue" title 'OpenTelemetry-java (No Logging)', \
	'results/evolution_OpenTelemetry-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'results/evolution_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	'results/evolution_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     'results/evolution_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry-java (Zipkin)', \
	'results/evolution_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5

	
unset output


set out 'results/ram_overview.pdf'

set title 'Change of RAM Usage Between Start and End'

set xlabel 'Call Tree Depth'
set ylabel 'RAM / MB'

set key left top
	
plot 'results/evolution_ram_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_ram_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_ram_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     'results/evolution_ram_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'results/evolution_ram_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	'results/evolution_ram_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     'results/evolution_ram_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	'results/evolution_ram_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     'results/evolution_ram_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	'results/evolution_ram_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	'results/evolution_ram_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	'results/evolution_ram_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	'results/evolution_ram_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	'results/evolution_ram_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5

	
unset output

set out 'results/ram_absolute_overview.pdf'

set title 'RAM Usage at Benchmark End'

set xlabel 'Call Tree Depth'
set ylabel 'RAM / MB'

set key left top
	
plot 'results/evolution_ram_absolute_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_ram_absolute_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_ram_absolute_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     'results/evolution_ram_absolute_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'results/evolution_ram_absolute_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	'results/evolution_ram_absolute_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     'results/evolution_ram_absolute_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	'results/evolution_ram_absolute_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     'results/evolution_ram_absolute_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	'results/evolution_ram_absolute_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	'results/evolution_ram_absolute_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	'results/evolution_ram_absolute_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	'results/evolution_ram_absolute_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	'results/evolution_ram_absolute_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5

	
unset output

set out 'results/gc_overview.pdf'

set title 'GC Count'

set xlabel 'Call Tree Depth'
set ylabel 'GC Count'

set key left top
	
plot 'results/evolution_gc_inspectIT-java.csv' u 1:2 w linespoint lc "red" title 'Baseline', \
	'results/evolution_gc_inspectIT-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'results/evolution_gc_Kieker-java.csv' u 1:10 w linespoint lc "blue" title 'Kieker-java (TCP)', \
     'results/evolution_gc_Kieker-java.csv' u 1:($10-$11):($10+$11) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'results/evolution_gc_inspectIT-java.csv' u 1:6 w linespoint lc rgb "#c66900" title 'inspectIT (Zipkin)', \
	'results/evolution_gc_inspectIT-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#c66900" notitle fs transparent solid 0.5, \
     'results/evolution_gc_OpenTelemetry-java.csv' u 1:8 w linespoint lc "green" title 'OpenTelemetry (Zipkin)', \
	'results/evolution_gc_OpenTelemetry-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     'results/evolution_gc_elasticapm-java.csv' u 1:6 w linespoint lc rgb "#FF50FF" title 'Elastic APM', \
	'results/evolution_gc_elasticapm-java.csv' u 1:($6-$7):($6+$7) w filledcurves lc rgb "#FF50FF" notitle fs transparent solid 0.5, \
	'results/evolution_gc_Skywalking-java.csv' u 1:4 w linespoint lc rgb "#FFAAFF" title 'Skywalking', \
	'results/evolution_gc_Skywalking-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc rgb "#FFAAFF" notitle fs transparent solid 0.5, \
	'results/evolution_gc_pinpoint-java.csv' u 1:8 w linespoint lc rgb "#FFAA00" title 'Pinpoint', \
	'results/evolution_gc_pinpoint-java.csv' u 1:($8-$9):($8+$9) w filledcurves lc rgb "#FFAA00" notitle fs transparent solid 0.5

	
unset output
