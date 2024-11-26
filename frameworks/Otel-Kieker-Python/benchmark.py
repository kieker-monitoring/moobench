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
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
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
output_filename = parser.get('Benchmark', 'output_filename')
empty_exporter_bool = parser.getboolean('Benchmark', 'empty_exporter')
custom_exporter = parser.getboolean('Benchmark', 'custom_exporter')
# debug

trace.set_tracer_provider(TracerProvider())
empty_exporter = EmptyExporter()
kieker_exporter = KiekerTcpExporter()

if empty_exporter_bool:
        span_processor = SimpleSpanProcessor(empty_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)
else:
    print("not empty")
    if custom_exporter:
        span_processor = SimpleSpanProcessor(kieker_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)
        
    else:
        otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
        span_processor = BatchSpanProcessor(otlp_exporter)
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
