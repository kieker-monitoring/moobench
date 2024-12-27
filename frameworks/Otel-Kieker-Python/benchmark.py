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
from exporter_wrapper import LatencyMeasuringExporter
# read argumetns
if len(sys.argv) < 2:
    print('Path to the benchmark configuration file was not provided.')

parser = configparser.ConfigParser()
parser.read(sys.argv[1])

total_calls =int(parser.get('Benchmark','total_calls'))
recursion_depth = int(parser.get('Benchmark','recursion_depth'))
method_time = int(parser.get('Benchmark','method_time'))
output_filename = parser.get('Benchmark', 'output_filename')
instrumentation_on = parser.getboolean('Benchmark', 'instrumentation_on')
batched_processor = parser.getboolean('Benchmark', 'batched_processor')
latency_filename =  parser.get('Benchmark', 'latency_filename')
# debug

trace.set_tracer_provider(TracerProvider())



if not instrumentation_on:
        print("No Monitoring")
        pass

else:

    if batched_processor:
        print("Batches")
        trace.set_tracer_provider(TracerProvider())
        kieker_exporter = KiekerTcpExporter()
        span_processor = BatchSpanProcessor(kieker_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)

        
    else:
        print("Simple Span")
        trace.set_tracer_provider(TracerProvider())
        otlp_exporter = KiekerTcpExporter()
        span_processor = SimpleSpanProcessor(otlp_exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)
#        print("collector")



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
    if not instrumentation_on:
        monitored_application.monitored_method_no_instrument(method_time, recursion_depth)
    else:
        monitored_application.monitored_method(method_time, recursion_depth)
    stop_ns = time.time_ns()
    timings.append(stop_ns-start_ns)
    if i%100000 == 0:
        print(timings[-1])
    
    output_file.write(f"{thread_id};{timings[-1]}\n")

output_file.close()

# end
