This is the first step towards using JMC.

After the agent is downloaded and built, its possible to start

```
java --add-opens java.base/jdk.internal.misc=ALL-UNNAMED -XX:+FlightRecorder -javaagent:jmc/agent/target/agent-1.0.1-SNAPSHOT.jar=jfr-probes.xml -jar ../../tools/benchmark/build/libs/benchmark.jar -a moobench.application.MonitoredClassSimple -o test.csv --recursion-depth 25 --total-threads 1 --total-calls 10000000 --method-time 10000 --quickstart
```

While this works starting the process itself, it doesn't yield JFR files, so there is something wrong here (probably in jfr-probes.xml).
