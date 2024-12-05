# -*- coding: utf-8 -*-

class BeforeOperationEvent:
    
    def __init__(self, timestamp, trace_id, order_index,
                 operation_signature, class_signature):
        self.timestamp = timestamp
        self.trace_id = trace_id
        self.order_index = order_index
        self.operation_signature = operation_signature
        self.class_signature = class_signature

    def serialize(self, serializer):
        serializer.put_long(self.timestamp)
        serializer.put_long(self.trace_id)
        serializer.put_int(self.order_index)
        serializer.put_string(self.operation_signature)
        serializer.put_string(self.class_signature)
    
    

class AfterOperationEvent:

    def __init__(self, timestamp, trace_id, order_index,
                 operation_signature, class_signature):
        self.timestamp = timestamp
        self.trace_id = trace_id
        self.order_index = order_index
        self.operation_signature = operation_signature
        self.class_signature = class_signature

    def serialize(self, serializer):
        serializer.put_long(self.timestamp)
        serializer.put_long(self.trace_id)
        serializer.put_int(self.order_index)
        serializer.put_string(self.operation_signature)
        serializer.put_string(self.class_signature)

        
class AfterOperationFailedEvent:

    def __init__(self, timestamp, trace_id, order_index,
                 operation_signature, class_signature, exception):
        self.timestamp = timestamp
        self.trace_id = trace_id
        self.order_index = order_index
        self.operation_signature = operation_signature
        self.class_signature = class_signature
        self.exception = exception

    def serialize(self, serializer):
        serializer.put_long(self.timestamp)
        serializer.put_long(self.trace_id)
        serializer.put_int(self.order_index)
        serializer.put_string(self.operation_signature)
        serializer.put_string(self.class_signature)
        serializer.put_string(self.exception)

class CallOperationEvent:
    
    def __init__(self, timestamp, trace_id, order_index, caller_operation_sig,
                 caller_class_sig, callee_operation_sig, callee_class_sig,
                 object_id, callee_object_id):
        
        self.timestamp =timestamp
        self.trace_id = trace_id
        self.order_index = order_index
        self.caller_oprtation_sig = caller_operation_sig
        self.caller_class_sig = caller_class_sig
        self.callee_operation_sig = callee_operation_sig
        self.callee_class_sig = callee_class_sig

        
        
    def serialize(self, serializer):
        
        serializer.put_long(self.timestamp)
        serializer.put_long(self.trace_id)
        serializer.put_int(self.order_index)
        serializer.put_string(self.callee_operation_sig)
        serializer.put_string(self.callee_class_sig)
        serializer.put_string(self.callee_operation_sig)
        serializer.put_string(self.callee_class_sig)


