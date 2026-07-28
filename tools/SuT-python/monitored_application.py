# -*- coding: utf-8 -*-
import time
def monitored_method(method_time, rec_depth, trace=None, tracer=None, parent_span=None):
    # OpenTelemetry-python
    if trace != None:
        ctx = trace.set_span_in_context(parent_span)
        span = tracer.start_span('monitored_method', context=ctx)
    else:
        span = None

    if rec_depth>1:
        return monitored_method(method_time, rec_depth-1,
                                trace=trace,
                                tracer=tracer,
                                parent_span=span)
    else:
        exit_time = time.time_ns()+method_time
        current_time = 0
        while True:
            current_time = time.time_ns()
            
            if current_time > exit_time:
                break
        return current_time
