import sys
import time
import configparser
import re
import os

try:
    from opentelemetry import trace
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.exporter.zipkin.json import ZipkinExporter
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.semconv.resource import ResourceAttributes
    OTEL_AVAILABLE = True
except ImportError:
    OTEL_AVAILABLE = False

try:
    from monitoring.controller import SingleMonitoringController
    from tools.importhookast import InstrumentOnImportFinder
    from tools.importhook import PostImportFinder
    KIEKER_AVAILABLE = True
except ImportError:
    KIEKER_AVAILABLE = False

if len(sys.argv) < 2:
    print('Path to the benchmark configuration file was not provided.')
    sys.exit(1)

parser = configparser.ConfigParser()
parser.read(sys.argv[1])

try:
    total_calls = int(parser.get('Benchmark','total_calls'))
    recursion_depth = int(parser.get('Benchmark','recursion_depth'))
    method_time = int(parser.get('Benchmark','method_time'))
    output_filename = parser.get('Benchmark', 'output_filename')
    ini_path = parser.get('Benchmark','config_path')
    inactive = parser.getboolean('Benchmark', 'inactive')
    instrumentation_on = parser.getboolean('Benchmark', 'instrumentation_on')
    approach = parser.getint('Benchmark', 'approach')
except Exception as e:
    print(f"Error parsing config: {e}")
    sys.exit(1)

# Setup Kieker only if requested
if KIEKER_AVAILABLE and instrumentation_on:
    # This segment runs only for the original Kieker framework logic
    some_var = SingleMonitoringController(ini_path)
    if approach == 2:
        sys.meta_path.insert(0, InstrumentOnImportFinder(ignore_list=[], empty=inactive, debug_on=False))
    else:
        pattern_object = re.compile('monitored_application')
        exclude_modules = list()
        sys.meta_path.insert(0, PostImportFinder(pattern_object, exclude_modules, empty=inactive))

# opentelemetry manual instrumentation
tracer = None
# Only enable if installed and requested via environment variable
enable_otel = os.environ.get("ENABLE_OTEL", "false").lower() == "true"

if OTEL_AVAILABLE and enable_otel:
    resource = Resource(attributes={
        ResourceAttributes.SERVICE_NAME: "moobench-python"
    })

    provider = TracerProvider(resource=resource)

    exporter_type = os.environ.get('OTEL_TRACES_EXPORTER', 'none')
    
    if exporter_type == 'zipkin':
        print("Initializing Zipkin Exporter...")
        zipkin_endpoint = os.environ.get('OTEL_EXPORTER_ZIPKIN_ENDPOINT', "http://localhost:9411/api/v2/spans")
        zipkin_exporter = ZipkinExporter(endpoint=zipkin_endpoint)
        provider.add_span_processor(BatchSpanProcessor(zipkin_exporter))

    trace.set_tracer_provider(provider)
    tracer = trace.get_tracer("moobench.benchmark")

import monitored_application

print(f"Writing results to: {output_filename}")
print(f"Starting execution: {total_calls} calls.")

output_file = open(output_filename, "w")
thread_id = 0

for i in range(total_calls):

    start_ns = time.time_ns()

    if OTEL_AVAILABLE and tracer:
        with tracer.start_as_current_span("monitored_method"):
            monitored_application.monitored_method(method_time, recursion_depth)
    else:
        monitored_application.monitored_method(method_time, recursion_depth)

    stop_ns = time.time_ns()

    duration = stop_ns - start_ns

    if i % 100000 == 0 and i > 0:
        print(f"Call {i}: {duration} ns")
    
    output_file.write(f"{thread_id};{duration}\n")

output_file.close()

if OTEL_AVAILABLE and os.environ.get('OTEL_TRACES_EXPORTER') == 'zipkin':
    print("Flushing traces to Zipkin (waiting 5s)...")
    time.sleep(5)

print("Benchmark finished.")