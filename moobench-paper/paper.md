---
title: 'MooBench: A micro-benchmark for performance overhead of observability tools'
tags:
  - Java
  - ...
authors:
  - name: David Georg Reichelt
    corresponding: true
    orcid: 0000-0002-1772-1416
    equal-contrib: true
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

# Statement of Need

Observability tools are crucial for managing software system health and optimizing operational costs; consequently, a wide variety of tools compete in the market [@GartnerObservability2025]. The relevance of distributed tracing tools increased with the rise of microservice architectures, where system behavior across microservices needs to be understood [@sigelman2010dapper]. While observabiliy generally consists of the three pillars traces, metrics, and logs, especially distributed tracing is gaining wide adoption [@janes2023open].

In the context of microservices, various studies have examined the overhead of tracing. For example, Nou et al. [@nou2025investigating] investigated the overhead of OpenTelemetry and Elastic APM using open-source applications, and examined the root causes of the overhead using profiling. Ahmed et al. [@ahmed2016studying] compared the overhead of commercial observability tools and the open-source tool Pinpoint for regression detection. Eder et al. [@eder2023comparison] compared the overhead using serverless applications.

Besides the microservice context, tracing overhead has been examined for operating systems and High-Performance Computing (HPC). For operating system, the overhead of tools for tracing the kernel itself [@desnoyers2006lttng] [@gebai2018tracers] and eBPF, that allows to trace both within the kernel and the user space [@volpertEBPFOverhead] [@domaschka2023using] has been examined in case studies. In the context of HPC, research has addressed the impact of overhead [@hunold2022overhead] and the combination of instrumentation and sampling to reduce it [@ilsche2015combining].

The aforementioned studies utilize macrobenchmarks to examine overhead in realistic use cases. While macrobenchmarks provide an indication of overhead in similar scenarios, they often fail to isolate the baseline overhead or identify its specific sources. When looking at specific distributed cases, the overhead sources are influenced by the processes running in parallel, their scheduling, and by the network behavior. MooBench addresses this by providing a microbenchmark that measures the fundamental overhead of observability frameworks in a controlled environment. Using different configurations, it enables factorial experiments that isolate root causes of overhead, specifically distinguishing between instrumentation, data collection, and data serialization.

# Architecture Overview

## Foundations

### Observability

### Performance Meaurement

## Architecture

# Research impact

### Analysis

There have been numerious case studies that examined overhead and its root causes.

Waller et al. [@waller2014application]...

Eichelberger et al. [@eichelberger2014flexible]...

Knoche et al. [@knoche2018using]...

### Improvement Case Studies

Strubel et al. [@strubel2016refactoring]...

Reichelt et al. [@reichelt2023towards]...

## Related Work

## Summary and Outlook

Main outlook ideas:
- Extend MooBench for measuring power consumption
- Extend MooBench for measuring observability for different technologies (JavaScript, c++, php, ...)
- Extend MooBench for memory usage (hard disk and heap)

# Acknowledgements

We acknowledge contributions from André van Hoorn, Reiner Jung, Thomas Düllmann, ...

# References

