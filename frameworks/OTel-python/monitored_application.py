# -*- coding: utf-8 -*-
import time
from opentelemetry import trace
from opentelemetry import metrics
tracer = trace.get_tracer("FF")

meter = metrics.get_meter(__name__)
request_counter = meter.create_counter(
    "method_invocation_count",
    description="Counts the number of method invocations",
)

def monitored_method_traces(method_time, rec_depth):
    with tracer.start_as_current_span("monitored_span") as span:
        if rec_depth>1:
            return monitored_method_traces(method_time, rec_depth-1)
        else:
            exit_time = time.time_ns()+method_time
            current_time = 0
            while True:
                current_time = time.time_ns()
            
                if current_time > exit_time:
                    break
            return current_time

def monitored_method_without(method_time, rec_depth):
    if rec_depth>1:
        return monitored_method_without(method_time, rec_depth-1)
    else:
        exit_time = time.time_ns()+method_time
        current_time = 0
        while True:
            current_time = time.time_ns()
            
            if current_time > exit_time:
                break
        return current_time

def monitored_method_prometheus(method_time, rec_depth):
    request_counter.add(1, {"method": "monitored_method_prometheus"})
    if rec_depth>1:
        return monitored_method_prometheus(method_time, rec_depth-1)
    else:
        exit_time = time.time_ns()+method_time
        current_time = 0
        while True:
            current_time = time.time_ns()
            
            if current_time > exit_time:
                break
        return current_time


