# -*- coding: utf-8 -*-
import time
from opentelemetry import trace
tracer = trace.get_tracer("tracer")
attributes = {
    "message": "Hello World!",
    "is_off": True,
    "int_num": 3,
    "branch_id": 2,
    "branching_outcome": 3,
    "long_num":34573070785363,
    "operation_signature" : "asdf",
    "session_id": "sjhi",
    "hostname":"buu",
    "eoi":0,
    "ess":1
    
    
}
def monitored_method(method_time, rec_depth):
    with tracer.start_as_current_span("monitored_span", attributes=attributes) as span:
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
