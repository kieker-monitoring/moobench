# -*- coding: utf-8 -*-
import threading

#from socket import *
from monitoring.record.trace.tracemetadata import TraceMetadata


lock = threading.Lock()
thread_local = threading.local()
thread_local.trace = None
thread_local.trace_stack = None


class _PointTrace:

    def __init__(self, trace_id, order_id):
        self.trace_id = trace_id
        self.order_id = order_id


class TraceRegistry:

    def __init__(self):
        self.next_order_id = 0
        self.next_trace_id = 0
        self.tracemetadata = None
        self.parent_trace = {}

    def get_trace(self):
        if not hasattr(thread_local, 'trace'):
            thread_local.trace = None
        return thread_local.trace

    def get_new_id(self):
        with lock:
            # THIS IS A WEIRD WAY TO INCREMENT
            # BUT FOR SOME REASON THE INCREMENTATION HAPPENS ONLY ONCE
            # IF WE DO IT THE NORMAL WAY. 
            tmp = self.next_trace_id
            self.next_trace_id = tmp + 1
            result = self.next_trace_id
        return 0 | result

    def get_and_remove_parent_trace_id(self, thread):
        lock.acquire()
        result = self.parent_trace.pop(thread, None)
        lock.release()
        return result

    def register_trace(self):
        # TODO Enclosing traces and stuff
       
        enclosing_trace = self.get_trace()
        if not enclosing_trace is None:
            local_trace_stack = thread_local.trace_stack
            if local_trace_stack is None:
                local_trace_stack = list()
                thread_local.trace_stack=local_trace_stack
            local_trace_stack.append(enclosing_trace)

        thread = threading.current_thread()
        trace_point = self.get_and_remove_parent_trace_id(thread)
        trace_id = self.get_new_id()
        parent_trace_id = None
        parent_order_id = None

        if not trace_point is None:
            
            parent_trace_id = trace_point.trace_id
            parent_order_id = trace_point.order_id
        elif not enclosing_trace is None:
            parent_trace_id = enclosing_trace.trace_id
            parent_order_id = -1
        else:
            parent_trace_id = trace_id
            parent_order_id = -1

        meta_record = TraceMetadata(trace_id,
                                    thread.ident,
                                    None,
                                    None,
                                    parent_trace_id,
                                    parent_order_id)
        thread_local.trace = meta_record
        return meta_record

    def unregister_trace(self):
        local_trace_stack=thread_local.trace_stack
        if not local_trace_stack is None :
            if local_trace_stack:
                thread_local.trace =thread_local.trace_stack.pop()
            else:
                thread_local.trace_stack=None
                thread_local.trace = None
        else:
            thread_local.trace = None