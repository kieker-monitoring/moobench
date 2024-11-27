import time
from opentelemetry.sdk.trace.export import SpanExporter

class LatencyMeasuringExporter(SpanExporter):
    def __init__(self, wrapped_exporter, file_name):
        self.wrapped_exporter = wrapped_exporter
        self.latencies = []  # Store latencies for analysis
        self.file_name = file_name

    def export(self, spans):
        start_time = time.time()
        result = self.wrapped_exporter.export(spans)
        end_time = time.time()
        
        latency = end_time - start_time
        self.latencies.append((latency, len(spans)))
       
        
        return result

    def shutdown(self):
        output_file = open(self.file_name, "w") 
        thread_id = 0
        for latency, length in self.latencies:
            output_file.write(f"{thread_id};{latency};{length}\n")
        output_file.close()
        self.wrapped_exporter.shutdown()
