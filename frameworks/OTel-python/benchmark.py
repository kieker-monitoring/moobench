# -*- coding: utf-8 -*-
# standard import
import sys
import time
import configparser
import re
# instrumentation
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, SimpleSpanProcessor

from emptyexporter import EmptyExporter
from kiekerexporter import KiekerTcpExporter
from kiekerprocessor import IncrementAttributeSpanProcessor
# read argumetns
if len(sys.argv) < 2:
    print('Path to the benchmark configuration file was not provided.')

parser = configparser.ConfigParser()
parser.read(sys.argv[1])

total_calls =int(parser.get('Benchmark','total_calls'))
recursion_depth = int(parser.get('Benchmark','recursion_depth'))
method_time = int(parser.get('Benchmark','method_time'))
ini_path = parser.get('Benchmark','config_path')
inactive = parser.getboolean('Benchmark', 'inactive')
instrumentation_on = parser.getboolean('Benchmark', 'instrumentation_on')
approach = parser.getint('Benchmark', 'approach')
output_filename = parser.get('Benchmark', 'output_filename')
empty_exporter = parser.getboolean('Benchmark', 'empty_exporter')
simple_processor = parser.getboolean('Benchmark', 'simple_processor')
# debug

trace.set_tracer_provider(TracerProvider())
otlp_exporter = KiekerTcpExporter()
empty_exporter = EmptyExporter()
kieker_exporter = KiekerTcpExporter()
# instrument


if empty_exporter:
    if simple_processor:
        span_processor = SimpleSpanProcessor(empty_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)
    else:
        span_processor = BatchSpanProcessor(empty_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)
else:
    if simple_processor:
        span_processor = SimpleSpanProcessor(kieker_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)
    else:
        span_processor = BatchSpanProcessor(kieker_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)



import monitored_application

# setup
output_file = open(output_filename, "w")

thread_id = 0

start_ns = 0
stop_ns = 0
timings = []

# run experiment
for i in range(total_calls):
    start_ns = time.time_ns()
    monitored_application.monitored_method(method_time, recursion_depth)
    stop_ns = time.time_ns()
    timings.append(stop_ns-start_ns)
    if i%100000 == 0:
        print(timings[-1])
    
    output_file.write(f"{thread_id};{timings[-1]}\n")

output_file.close()

# end
