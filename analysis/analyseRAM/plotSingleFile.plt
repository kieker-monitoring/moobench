set encoding iso_8859_1
set terminal pdf size 8,5

set datafile separator ";"

set out 'single-file-evolution.pdf'

set title 'Duration and RAM Usage Evolution'

set xlabel 'Iteration'
set ylabel 'Duration {/Symbol m}s'
set y2label 'RAM Usage / MB'

set key right top

set y2tics

set yrange [0:*]
set y2range [0:*]
	
plot 'selected_file.csv' u ($0*1000):1 w linespoint lc "blue" title 'Duration', \
	'selected_file.csv' u ($0*1000):($2/1000000) w linespoint lc "red" axis x1y2 title 'RAM'
	
unset output
