# -*- coding: utf-8 -*-
import time

def get_prefix(class_name):
    events = ["BeforeOperationEvent", "AfterOperationEvent", "AfterOperationFailedEvent"]
    metadata = ["TraceMetadata"]

    if class_name  in events:
        return 'kieker.common.record.flow.trace.operation.'
    elif class_name in metadata:
        return 'kieker.common.record.flow.trace.'


class TimeStamp:
    
    def get_time(self):
        timestamp = time.time_ns()
        return timestamp