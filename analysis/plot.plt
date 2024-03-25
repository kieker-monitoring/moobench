set encoding iso_8859_1
set terminal pdf size 4,2

set datafile separator ";"

set out 'technologies_steady.pdf'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'

set key left top
	
plot 'OpenTelemetry-java.csv' u 1:2 w linespoint lc "red" title 'OpenTelemetry', \
       'OpenTelemetry-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'Kieker-java-bytebuddy.csv' u 1:2 w linespoint lc "blue" title 'ByteBuddy', \
       'Kieker-java-bytebuddy.csv' u 1:($2-$3):($2+$3) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'Kieker-java.csv' u 1:2 w linespoint lc "yellow" title 'AspectJ', \
       'Kieker-java.csv' u 1:($2-$3):($2+$3) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     'Kieker-java-DiSL.csv' u 1:2 w linespoint lc "green" title 'DiSL',  \
       'Kieker-java-DiSL.csv' u 1:($2-$3):($2+$3) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     'Kieker-java-javassist.csv' u 1:2 w linespoint lc "orange" title 'Javassist', \
       'Kieker-java-javassist.csv' u 1:($2-$3):($2+$3) w filledcurves lc "orange" notitle fs transparent solid 0.5, \
     'Kieker-java-sourceinstrumentation.csv' u 1:2 w linespoint lc "purple" title 'Source Instr.',  \
       'Kieker-java-sourceinstrumentation.csv' u 1:($2-$3):($2+$3) w filledcurves lc "purple" notitle fs transparent solid 0.5

	
unset output


set out 'technologies_warmup.pdf'

set xlabel 'Call Tree Depth'
set ylabel 'Duration {/Symbol m}s'
	
plot 'OpenTelemetry-java.csv' u 1:4 w linespoint lc "red" title 'OpenTelemetry', \
       'OpenTelemetry-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "red" notitle fs transparent solid 0.5, \
     'Kieker-java-bytebuddy.csv' u 1:4 w linespoint lc "blue" title 'ByteBuddy', \
       'Kieker-java-bytebuddy.csv' u 1:($4-$5):($4+$5) w filledcurves lc "blue" notitle fs transparent solid 0.5, \
     'Kieker-java.csv' u 1:4 w linespoint lc "yellow" title 'AspectJ', \
       'Kieker-java.csv' u 1:($4-$5):($4+$5) w filledcurves lc "yellow" notitle fs transparent solid 0.5, \
     'Kieker-java-DiSL.csv' u 1:4 w linespoint lc "green" title 'DiSL',  \
       'Kieker-java-DiSL.csv' u 1:($4-$5):($4+$5) w filledcurves lc "green" notitle fs transparent solid 0.5, \
     'Kieker-java-javassist.csv' u 1:2 w linespoint lc "orange" title 'Javassist', \
       'Kieker-java-javassist.csv' u 1:($2-$3):($2+$3) w filledcurves lc "orange" notitle fs transparent solid 0.5, \
     'Kieker-java-sourceinstrumentation.csv' u 1:4 w linespoint lc "purple" title 'Source Instr.',  \
       'Kieker-java-sourceinstrumentation.csv' u 1:($4-$5):($4+$5) w filledcurves lc "purple" notitle fs transparent solid 0.5

	
unset output
