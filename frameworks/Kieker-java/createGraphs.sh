sudo chown $(whoami):$(whoami) perf*
perf script -i perf_2_1.data | $FLAME_HOME/stackcollapse-perf.pl > nologging.folded
cat nologging.folded | $FLAME_HOME/flamegraph.pl > nologging.svg
perf script -i perf_4_1.data | $FLAME_HOME/stackcollapse-perf.pl > binary.folded
cat binary.folded | $FLAME_HOME/flamegraph.pl > binary.svg
$FLAME_HOME/difffolded.pl nologging.folded binary.folded | $FLAME_HOME/flamegraph.pl > diffNoLogging.svg
$FLAME_HOME/difffolded.pl binary.folded nologging.folded | $FLAME_HOME/flamegraph.pl > diffBinary.svg

mkdir graphs
mv perf_*.data graphs
mv *.svg graphs
mv *.folded graphs
