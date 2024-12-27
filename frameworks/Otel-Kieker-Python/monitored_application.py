# -*- coding: utf-8 -*-
import time
from opentelemetry import trace
tracer = trace.get_tracer("test")
attributes = {
    "operation_signature" : "asdf",
    "session_id": "sjhi",
    "hostname":"buu",
    "eoi":0,
    "ess":1
    
    
}
def monitored_method(method_time, rec_depth):
    with tracer.start_as_current_span("Foo", attributes=attributes) as span:
        if rec_depth>1:
            return monitored_method(method_time, rec_depth-1)
        else:
            exit_time = time.time_ns()+method_time
            current_time = 0
            while True:
                current_time = time.time_ns()
            
                if current_time > exit_time:
                    break
    
            return current_time

def monitored_method_no_instrument(method_time, rec_depth):
    if rec_depth>1:
        return monitored_method_no_instrument(method_time, rec_depth-1)
    else:
        exit_time = time.time_ns()+method_time
        current_time = 0
        while True:
            current_time = time.time_ns()
            
            if current_time > exit_time:
                break
    
        return current_time
