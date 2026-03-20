---
title: 'MooBench: A micro-benchmark for performance overhead of observability tools'
tags:
  - Java
  - ...
authors:
  - name: David Georg Reichelt
    corresponding: true
    orcid: 0000-0002-1772-1416
    affiliation: "1, 2"
  - name: Shinhyung Yang
    orcid: 0000-0002-8997-9942
    affiliation: 3
  - name: Marcel Hansson
    orcid: 0009-0000-6524-037X
    affiliation: 4
  - name: Wilhelm Hasselbring
    affiliation: 3
    orcid: 0000-0001-6625-4335
affiliations:
 - name: Lancaster University Leipzig
   index: 1
 - name: Universitätsrechenzentrum (URZ) Leipzig
   index: 2
 - name: Kiel University
   index: 3
 - name: University of Hamburg
   index: 4
date: 12 March 2026
bibliography: paper.bib

aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
---

# Summary

Understanding the runtime behavior of software is inherently difficult due to the unpredictability of the behavior itself and the non-determinism of underlying layers, such as Just-In-Time (JIT) compilation in virtual machines, operating system scheduling, and CPU frequency scaling. Observability tools aim to answer questions regarding runtime behavior of software, such as "How much time did this request take?" or "How often did method A call method B?" [@majors2022observability]. These questions are answered using telemetry data, i.e., measurement data that is obtained from the code execution. To collect telemetry data, additional code needs to be executed, which introduces overhead. This overhead affects both system performance and the accuracy of the measurements themselves. The MooBench microbenchmark measures this overhead and contains factorial experiments that facilitate breaking down this overhead into its root causes.

The MooBench benchmark has been originally developed to examine the performance overhead of Kieker in Java and was extended as a general overhead measurement microbenchmark for various observability tools, currently within the Java and Python ecosystem. In this paper, we describe the MooBench microbenchmark.

# Statement of need

Observability tools are crucial for managing software system health and optimizing operational costs; consequently, a wide variety of tools compete in the market [@GartnerObservability2025]. The relevance of distributed tracing tools increased with the rise of microservice architectures, where system behavior across microservices needs to be understood [@sigelman2010dapper]. While observabiliy generally consists of the three pillars traces, metrics, and logs, especially distributed tracing is gaining wide adoption [@janes2023open].

In the context of microservices, various studies have examined the overhead of tracing. For example, Nou et al. [@nou2025investigating] investigated the overhead of OpenTelemetry and Elastic APM using open-source applications, and examined the root causes of the overhead using profiling. Ahmed et al. [@ahmed2016studying] compared the overhead of commercial observability tools and the open-source tool Pinpoint for regression detection. Eder et al. [@eder2023comparison] compared the overhead using serverless applications.

Besides the microservice context, tracing overhead has been examined for operating systems and High-Performance Computing (HPC). For operating system, the overhead of tools for tracing the kernel itself [@desnoyers2006lttng] [@gebai2018tracers] and eBPF, that allows to trace both within the kernel and the user space [@volpertEBPFOverhead] [@domaschka2023using] has been examined in case studies. In the context of HPC, research has addressed the impact of overhead [@hunold2022overhead] and the combination of instrumentation and sampling to reduce it [@ilsche2015combining].

The aforementioned studies utilize macrobenchmarks to examine overhead in realistic use cases. While macrobenchmarks provide an indication of overhead in similar scenarios, they often fail to isolate the baseline overhead or identify its specific sources. When looking at specific distributed cases, the overhead sources are influenced by the processes running in parallel, their scheduling, and by the network behavior. MooBench addresses this by providing a microbenchmark that measures the fundamental overhead of observability frameworks in a controlled environment. Using different configurations, it enables factorial experiments that isolate root causes of overhead, specifically distinguishing between instrumentation, data collection, and data serialization.

# Software design

MooBench consists of two parts: the minimal and configurable system under test, and the automation of benchmarking the observability. These are described in the following.

## System under test

The overhead of observability tools is caused by data collection. For tracing tools, this data collection is caused by method execution. The runtime behavior of the execution of methods is influenced by various factors, including class loading, Just-in-Time compilation (JIT), and garbage collection. To minimize these effects, MooBenchs SuT consists of only one method (`monitoredMethod`) that calls itself recursively `$RECURSION_DEPTH` times. Only this recursive calls could be removed by the JIT compiler, therefore, the last method call contains a busy wait for `$METHOD_TIME` nanoseconds. Figure [@fig:moobench] visualizes the call tree.

![Call tree of the MooBench microbenchmark showing the recursive method calls to control the stack depth. \label{fig:moobench}](calltree-1.svg)

This system under test is currently implemented in Java and Python. It is planned to extend it for JavaScript and Go.

## Observability automation

Each observability framework requires a different setup and has different capabilities. For example, OpenTelemetry can be attached to the JVM using `-javaagent`, requires the property otel.instrumentation.methods.include to be set to a list of classes, and can then export to Zipkin, Jaeger, or Prometheus. Furthermore, OpenTelemetry can be started with empty otel.instrumentation.methods.include or without export, which enables measuring the overhead of instrumentation without data collection or data collection without serialization. Due to these different configurations, it is necessary to implement configuration scripts for every framework individually. MooBench has these configuration scripts in `frameworks/$TECHNOLOGY-$LANGUAGE` (e.g., `frameworks/OpenTelemetry-java`). The scripts usually contain a `benchmark.sh` for starting the experiment, `functions.sh` with specific download or execution functions, `labels.sh` containing the names of the configurations and `config.rc` containing eventually necessary definitions of additional environment variables.

To measure performance in managed runtimes like the JVM, the managed runtime needs to be started multiple times, inside of the managed runtime, the workload needs to be repeated until a given count of warmup iterations is finished, and finally, the measurement iterations within the managed runtime need to be executed [@georges2007statistically]. MooBench implements this process by executing `$NUM_OF_LOOPS` loops, where every loop runs all configurations of one framework. Inside of each run, `$TOTAL_NUM_OF_CALLS` defines the number of iterations, i.e., repetitions of all calls to `monitoredMethod`. The execution data are stored into csv files, and after the execution is finished, the warmup iterations are removed.

# Research impact statement

There have been numerious case studies that examined overhead and its root causes.

Waller et al. [@waller2014application]...

Eichelberger et al. [@eichelberger2014flexible]...

Knoche et al. [@knoche2018using]...

Reichelt et al. [@reichelt2021overhead]...

## Improvement Case Studies

Strubel et al. [@strubel2016refactoring]...

Reichelt et al. [@reichelt2023towards]...

Reichelt et al. [@reichelt2024overhead]...

Yang et al. [@yang2024evaluating]...

## MooBench development papers

Should include [@yang2025detection], [@reichelt2024overhead]?

# AI usage disclosure

There is no known AI usage, however, AI usage in PRs is not monitored. 

# Acknowledgements

We acknowledge contributions from André van Hoorn, Reiner Jung, Thomas Düllmann, ...

# References

