#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat May 28 23:53:36 2022

@author: serafim
"""
class BeforeOperationObjectEvent:
    
    def __init__(self, timestamp, trace_id, order_index, operation_sig,
                 class_sig, object_id ):
        
        self.timpestamp = timestamp
        self.trace_id = trace_id
        self.order_index = order_index
        self.operation_sig = operation_sig
        self.class_sig = class_sig
        self.object_id = object_id
        
    def serialize(self, serializer):
         serializer.put_long(self.timestamp)
         serializer.put_long(self.trace_id)
         serializer.put_int(self.order_index)
         serializer.put_string(self.operation_sig)
         serializer.put_string(self.class_sig)
         serializer.put_int(self.object_id)


class AfterOperationObjectEvent:
        
        def __init__(self, timestamp, trace_id, order_index, operation_sig,
                     class_sig, object_id ):
            
            self.timpestamp = timestamp
            self.trace_id = trace_id
            self.order_index = order_index
            self.operation_sig = operation_sig
            self.class_sig = class_sig
            self.object_id = object_id
            
        def serialize(self, serializer):
             serializer.put_long(self.timestamp)
             serializer.put_long(self.trace_id)
             serializer.put_int(self.order_index)
             serializer.put_string(self.operation_sig)
             serializer.put_string(self.class_sig)
             serializer.put_int(self.object_id)
             
class AfteFailerOperationObjectEvent:
        
        def __init__(self, timestamp, trace_id, order_index, operation_sig,
                     class_sig, cause, object_id ):
            
            self.timpestamp = timestamp
            self.trace_id = trace_id
            self.order_index = order_index
            self.operation_sig = operation_sig
            self.class_sig = class_sig
            self.object_id = object_id
            self.cause = cause
            
        def serialize(self, serializer):
             serializer.put_long(self.timestamp)
             serializer.put_long(self.trace_id)
             serializer.put_int(self.order_index)
             serializer.put_string(self.operation_sig)
             serializer.put_string(self.class_sig)
             serializer.put_string(self.cause)
             serializer.put_int(self.object_id)
     
            
class CallOperationObjectEvent:
    
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
        self.object_id = object_id
        self.callee_object_id = callee_object_id
        
        
    def serialize(self, serializer):
        
        serializer.put_long(self.timestamp)
        serializer.put_long(self.trace_id)
        serializer.put_int(self.order_index)
        serializer.put_string(self.callee_operation_sig)
        serializer.put_string(self.callee_class_sig)
        serializer.put_string(self.callee_operation_sig)
        serializer.put_string(self.callee_class_sig)
        serializer.putInt(self.object_id)
        serializer.putInt(self.callee_object_id)
