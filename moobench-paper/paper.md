---
title: 'MooBench: A micro-benchmark for performance overhead measurement of observability tools'
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

Understanding the runtime behavior of software is inherently difficult due to the unpredictability of the software's behavior itself and the non-determinism of underlying layers, such as Just-In-Time (JIT) compilation in virtual machines, operating system scheduling, and CPU frequency scaling. Observability tools aim to answer questions regarding runtime behavior of software, such as "How much time did this request take?" or "How often did method A call method B?" [@majors2022observability]. These questions are answered using telemetry data, i.e., measurement data that is obtained from the code execution. To collect telemetry data, additional code needs to be executed, which introduces overhead. This overhead affects both system performance and the accuracy of the measurements themselves. The MooBench microbenchmark measures this overhead and contains factorial experiments that facilitate breaking down this overhead into its root causes.

The MooBench benchmark was originally developed to examine the performance overhead of the Kieker monitoring framwork [@kieker2012] [@yang2025kieker] [@Kieker2020] in Java [@waller2013benchmark] and was extended as a general overhead measurement microbenchmark for various observability tools, currently within the Java and Python ecosystem. In this paper, we describe why it is needed, how it is structured, and how it is used in research.

# Statement of need

Observability tools are crucial for managing software system health and optimizing operational costs; consequently, a wide variety of tools compete in the market [@GartnerObservability2025]. The relevance of distributed tracing tools increased with the rise of microservice architectures, where system behavior across microservices needs to be understood [@sigelman2010dapper]. While observability generally consists of the three pillars traces, metrics, and logs, especially distributed tracing is gaining wide adoption [@janes2023open].

# State of the field

In the context of microservices, various studies have examined the overhead of tracing. For example, Nou et al. [@nou2025investigating] investigated the overhead of OpenTelemetry and Elastic APM using open-source applications, and examined the root causes of the overhead using profiling. Ahmed et al. [@ahmed2016studying] compared the overhead of commercial observability tools and the open-source tool Pinpoint for regression detection. Eder et al. [@eder2023comparison] compared the overhead using serverless applications.

Besides the microservice context, tracing overhead has been examined for operating systems and High-Performance Computing (HPC). For operating systems, the overhead of tools for tracing the kernel itself [@desnoyers2006lttng] [@gebai2018tracers] and eBPF, that allows to trace both within the kernel and the user space [@volpertEBPFOverhead] [@domaschka2023using], has been examined in case studies. In the context of HPC, research has addressed the impact of overhead [@hunold2022overhead] and the combination of instrumentation and sampling to reduce it [@ilsche2015combining].

The aforementioned studies utilize macrobenchmarks to examine overhead in realistic use cases. While macrobenchmarks provide an indication of overhead in similar scenarios, they often fail to isolate the baseline overhead or identify its specific sources. When looking at specific distributed cases, the overhead sources are influenced by the processes running in parallel, their scheduling, and the network behavior. MooBench addresses this by providing a microbenchmark that measures the fundamental overhead of observability frameworks in a controlled environment. Using different configurations, it enables factorial experiments that isolate root causes of overhead, specifically distinguishing between instrumentation, data collection, and data serialization.

Furthermore, macrobenchmarks are also time-consuming to execute. The MooBench microbenchmark was included early in Kiekers CI setup [@waller2015including], enabling the detection of performance regressions and the check of performance improvements in daily development.

# Software design

MooBench consists of two parts: the minimal and configurable system under test, and the automation of benchmarking observability frameworks. These are described in the following.

## System under test

The overhead of observability tools is caused by data collection. The amount of collected data -- and therefore the overhead -- scales with the number of observed method executions. However, the resource consumption of both, the application methods and the associated telemetry code, is non-deterministic and influenced by various factors, including class loading, Just-in-Time compilation (JIT), and garbage collection. To reduce the variance, the core of MooBench’s SuT is a single method (`monitoredMethod`) that calls itself recursively `$RECURSION_DEPTH` times. Because the JIT compiler could potentially optimize away these recursive calls, the last method call contains a busy wait for `$METHOD_TIME` nanoseconds. \autoref{fig:calltree} visualizes the call tree.

![Call tree of the MooBench microbenchmark showing the recursive method calls to control the stack depth [@reichelt2023towards]. \label{fig:calltree}](calltree.pdf){width=100% }

This system under test is currently implemented in Java and Python. It is planned to extend it for JavaScript and Go.

## Automation of benchmarking observability frameworks

Each observability framework requires a unique setup and has different capabilities. For example, OpenTelemetry can be attached to the JVM using `-javaagent`, which requires the property `otel.instrumentation.methods.include` to be set to a specific list of classes. OpenTelemetry can export data to Zipkin, Jaeger, or Prometheus. Furthermore, OpenTelemetry can be started with an empty `otel.instrumentation.methods.include` or without export, which enables measuring the overhead of instrumentation without data collection or data collection without serialization. Due to these different configurations, it is necessary to implement configuration scripts for each framework individually.

MooBench stores these configuration scripts in `frameworks/$TECHNOLOGY-$LANGUAGE` (e.g., `frameworks/OpenTelemetry-java`). The scripts typically contain a `benchmark.sh` for starting the experiment, `functions.sh` with specific download or execution functions, `labels.sh` containing the names of the configurations and `config.rc` containing optional definitions of additional environment variables.

To measure performance in managed runtimes like the JVM, the managed runtime needs to be started multiple times. Within each instance, the workload must be repeated until a given count of warmup iterations is finished, and finally, the measurement iterations within the managed runtime need to be executed [@georges2007statistically]. MooBench implements this process by executing `$NUM_OF_LOOPS` loops, where each loop runs all configurations of one framework. Inside of each run, `$TOTAL_NUM_OF_CALLS` defines the number of iterations, i.e., repetitions of all calls to `monitoredMethod`. The execution data are stored into CSV files, and after the execution is finished, the warmup iterations are truncated.

# Research impact statement

There have been numerous case studies that examined overhead of observability frameworks, and its root causes. Furthermore, there have been studies working on MooBench's continuous execution for regression benchmarking.

## Overhead analysis

[@eichelberger2014flexible] describe and develop SPASS-meter, an observability tool for Java and Android applications. To evaluate its overhead, they integrated SPASS-meter into MooBench [@eichelberger2016reproducibility]. Based on this work, [@knoche2018using] compared the overhead measurement of SPASS-meter and Kieker on a Raspberry Pi. They found that the results were reproducible across different Raspberry Pi units, indicating that such hardware provides a viable means for researchers to achieve reproducible performance benchmarks.

[@reichelt2021overhead] integrated OpenTelemetry into MooBench and compared the overhead of Kieker, OpenTelemetry and inspectIT using MooBench. They found that the tracing overhead for Kieker was 4.6 $\mu$s, OpenTelemetry was 6.8 $\mu$s, and inspectIT was 10.9 $\mu$s. This indicates that Kieker's overhead was significantly lower than the overhead of OpenTelemetry at the time of the study.

[@waller2012comparison] examined how multi-core environments influence the overhead of observability with Kieker. They concluded that across all tested systems, asynchronous writing on multi-core architectures leads to a significant reduction of overhead.

[@yang2024evaluating] compared the overhead of Cloudprofiler [@yang2023cloudprofilertscbasedinternodeprofiling], a monitoring application for stream processing workloads, to Kieker and OpenTelemetry. They found that Cloudprofiler's overhead (2.28 $\mu$s) is on average lower than the overhead introduced by Kieker (7.127 $\mu$s) and OpenTelemetry (higher, but only visible in a graph).

In our most recent study [@reichelt2026benchmarking], we integrated Pinpoint, Scouter, Skywalking, and Elastic APM into MooBench, measured the overhead of all frameworks, and examined the root causes of overhead. We found the rank order of overhead to be $$\mbox{Kieker} < \mbox{OpenTelemetry} < \mbox{Elastic APM} < \mbox{Skywalking} < \mbox{inspectIT},$$ with all observability frameworks scaling linearly. For Scouter and Pinpoint, we observed that their overhead increases very slow since they lose records, i.e., they contain functional bugs. By profiling the overhead using async-profiler, we attributed the overhead to the categories time function calls, metadata management, call tree collection, memory management, and queue management. Notably, we found that a significant portion of the overhead is caused by extensive metadata management. The software version for this study was awarded the Available, Functional, and Reusable badges for the ICPE 2026 Artifact Evaluation Track [@reichelt2026benchmarkingartifact].\footnote{\url{https://icpe2026.spec.org/tracks-and-submissions/artifact-evaluation-track/}}


## Observability framework improvement and optimization

[@strubel2016refactoring] examined how rewriting Kieker's monitoring component could reduce tracing overhead. Using MooBench, they demonstrated that their suggested rewrite reduced the overhead to 17% of the original measurement.

[@reichelt2023towards] examined different options for overhead reduction for tracing: Using source code instrumentation instead of AspectJ [@eclipse2026aspectj], storing only limited metadata, using a different queue and aggregating performance data before writing it to the monitoring queue. Using MooBench, they found that on their examined hardware, they could reduce the overhead from 4.77 ns to 0.4 ns per method call.

[@reichelt2024overhead] compared the overhead of the instrumentation frameworks AspectJ, ByteBuddy [@rafael2025bytebuddy], DiSL [@marek2012disl], Javassist and [shigeru2023disl] direct source code instrumentation. To do so, they extended the Kieker-java scripts of MooBench. Through these extensions of Kieker and MooBench, they found that while source code instrumentation has the lowest overhead, ByteBuddy, DiSL and Javassist also have comparably low overhead. AspectJ causes significantly higher overhead than the others. Based on these findings, the Kieker framework transitioned to using the Kieker ByteBuddy agent as its default.

## Continuous execution for regression benchmarking

Several authors worked on continuously executing MooBench benchmarks for spotting performance regressions in observability frameworks. [@waller2014application] started to include MooBench's benchmarking into CI. To reduce perturbations from concurrently running software, they configured Jenkins to execute measurements on a separate server. This setup is continually running until today, with regular hardware and system software updates. Additionally, a performance measurement setup for GitHub Actions was developed [@reichelt2024overhead]. This additional setup utilizes GitHub's default runners, that, despite sharing the execution infrastructure with others, show low standard deviation and lower execution times than the original Jenkins setup. The measurement data from GitHub have been uploaded to Nyrkiö, a performance change detection tool for GitHub Actions. Using this tool, past regressions could be reproduced [@yang2025detection]. In the future, it is planned to automatically detect performance regressions.

# AI usage disclosure

There is no known AI usage, however, AI usage in PRs is not monitored.

# Acknowledgements

We acknowledge contributions over the years from André van Hoorn, Jan Waller, Reiner Jung, Christian Wulf, Florian Fittkau, Ferit Altin, Serafim Simonov, and Nils Christian Ehmke.

# References

