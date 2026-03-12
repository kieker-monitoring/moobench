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

Runtime behavior of a software is inherently difficult to understand due to the unpredictability of the behavior itself and non-determinism of the underlying layers, e.g., the JIT of virtual machines, the operating systems scheduling processes, and the frequency scaling of the CPU. Observability tools aim to enable answering questions regarding runtime behavior of software, like "How much time did this request take?" and "How often did method A call method B?". This relies on telemetry data, i.e., measurement data that is obtained from the code execution. To get telemetry data, additional code needs to be executed, which creates overhead. This overhead both affects the system performance and the accuracy of the measurements itself. The MooBench microbenchmark measures this overhead and contains factorial experiments that facilitate breaking down this overhead into its root causes.

The MooBench benchmark has been originally developed to examine the performance overhead of Kieker in Java and was extended as a general overhead measurement microbenchmark for various observability tools, currently within the Java and Python ecosystem. In this paper, we describe the MooBench microbenchmark.

## Foundations

### Observability

### Performance Meaurement

## Architecture

## Past Applications

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

