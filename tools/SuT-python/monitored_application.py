# -*- coding: utf-8 -*-
import time
def monitored_method(method_time, rec_depth):
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
        
def monitored_method_otel(method_time, rec_depth, tracer):
    with tracer.start_as_current_span("monitored_method") as span:
        if rec_depth>1:
            return monitored_method_otel(method_time, rec_depth-1,
                                    tracer=tracer)
        else:
            exit_time = time.time_ns()+method_time
            current_time = 0
            while True:
                current_time = time.time_ns()
            
                if current_time > exit_time:
                    break
            return current_time
