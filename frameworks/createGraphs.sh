perf script -i Kieker-java-sourceinstrumentation/perf_3_1.data | $FLAME_HOME/FlameGraph/stackcollapse-perf.pl &> si.folded
cat si.folded | $FLAME_HOME/FlameGraph/flamegraph.pl > si.svg

perf script -i Kieker-java-javassist/perf_4_1.data | $FLAME_HOME/FlameGraph/stackcollapse-perf.pl &> javassist.folded
cat javassist.folded | $FLAME_HOME/FlameGraph/flamegraph.pl > javassist.svg

$FLAME_HOME/FlameGraph/difffolded.pl si.folded javassist.folded | $FLAME_HOME/FlameGraph/flamegraph.pl &> diff.svg
