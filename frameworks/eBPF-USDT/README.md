## eBPF-USDT Framework for MooBench

Traces Java method calls using eBPF USDT via `-XX:+DTraceMethodProbes`.

## Requirements

| Requirement | Version |
|---|---|
| Linux kernel | ≥ 5.15 |
| OpenJDK | 21+ |
| Architecture | `x86_64` or `aarch64` |
| clang | any recent version |
| g++ | any recent version |
| libbpf-dev | Ubuntu/Debian: `sudo apt install libbpf-dev` / RHEL-based: `sudo dnf install libbpf-devel` |
| r-base | Ubuntu/Debian: `sudo apt install r-base` / RHEL-based: `sudo dnf install R-base` |

## Installation

Build the tracer from inside the framework directory:

```bash
cd path/to/moobench/frameworks/eBPF-USDT
make
```

`make` will:
- Grant the tracer the Linux capabilities it needs (`cap_bpf`, `cap_perfmon`)

The `setcap` step requires sudo every time you compile the tracer

## Running the benchmark

```bash
./benchmark.sh
```

Results are written to `results-eBPF-USDT/`. Binary trace files (write mode) are written to `data/`.

## Configurations

| Index | Description |
|---|---|
| 0 | No instrumentation — baseline |
| 1 | `-XX:+DTraceMethodProbes` enabled, no tracer attached |
| 2 | Tracer attached, count mode (events consumed but not written) |
| 4 | Tracer attached, write mode (events written to binary file) |

## How it works

The benchmark uses a fake `JAVA_HOME` to intercept Java invocations and route them
through `java_wrapper.sh`. The wrapper starts Java normally, waits for `libjvm.so` to
load, then attaches the tracer process which loads the BPF programs and hooks into the
HotSpot `method__entry` and `method__return` USDT probes.

The BPF programs filter events to only the target class (`MonitoredClassSimple`) and
records data in a ring buffer, which the userspace tracer drains continuously.
