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
from opentelemetry.exporter.zipkin.json import ZipkinExporter
from opentelemetry.exporter import jaeger
from opentelemetry.sdk.resources import Resource
# read argumetns
if len(sys.argv) < 2:
    print('Path to the benchmark configuration file was not provided.')

parser = configparser.ConfigParser()
parser.read(sys.argv[1])

total_calls =int(parser.get('Benchmark','total_calls'))
recursion_depth = int(parser.get('Benchmark','recursion_depth'))
method_time = int(parser.get('Benchmark','method_time'))
ini_path = parser.get('Benchmark','config_path')
instrumentation_on = parser.getboolean('Benchmark', 'instrumentation_on')
approach = parser.getint('Benchmark', 'approach')
output_filename = parser.get('Benchmark', 'output_filename')

# debug



# instrument


if  instrumentation_on:
    if approach == 1: # No Exporters
        print("No exporter")
        trace.set_tracer_provider(TracerProvider())    
    elif approach ==3: # Jaeger
        print("Jaeger")
        
        resource = Resource.create({"service.name": "hello-world-service"})
        tracer_provider = TracerProvider(resource=resource)
        tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint="localhost:4317", insecure=True)))
        trace.set_tracer_provider(tracer_provider)

        
#        trace.set_tracer_provider(TracerProvider(resource=Resource.create({"service.name": "hello-world-service"})))
#        jaeger_exporter = OTLPSpanExporter(endpoint="localhost:4317", insecure=True)
#        span_processor = BatchSpanProcessor(exp)
#        trace.get_tracer_provider().add_span_processor(span_processor)
    elif approach == 2: # Zipkin
        print("Zipkin")
        TracerProvider(resource=Resource.create({"service.name": "hello-world-service"}))
        exp = zipkin_exporter = ZipkinExporter(endpoint="http://localhost:9411/api/v2/spans")
        span_processor = BatchSpanProcessor(exp)
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
    if not instrumentation_on:
        monitored_application.monitored_method_without(method_time, recursion_depth)
    else:
        monitored_application.monitored_method_traces(method_time, recursion_depth)
    stop_ns = time.time_ns()
    timings.append(stop_ns-start_ns)
    if i%100000 == 0:
        print(timings[-1])
    
    output_file.write(f"{thread_id};{timings[-1]}\n")

output_file.close()

# end
