# -*- coding: utf-8 -*-

class TraceMetadata:
    __NO_PARENT_TRACEID__ = -1
    __NO_PARENT_ORDER_INDEX__ = -1
    __NO_SESSION_ID__ = "<no-session-id>"
    __NO_HOSTNAME__ = "<default-host>"

    def __init__(self, trace_id, thread_id,
                 session_id, hostname,
                 parent_trace_id,
                 parent_order_id):
        self.trace_id = trace_id
        self.thread_id = thread_id
        self.session_id = (self.__NO_SESSION_ID__
                           if session_id is None
                           else session_id)
        self.hostname = (self.__NO_HOSTNAME__
                         if hostname is None
                         else hostname)
        self.parent_trace_id = parent_trace_id
        self.parent_order_id = parent_order_id
        self.next_order_id = 0
        pass

    def serialize(self, serializer):
        serializer.put_long(self.trace_id)
        serializer.put_long(self.thread_id)
        serializer.put_string(self.session_id)
        serializer.put_string(self.hostname)
        serializer.put_long(self.parent_trace_id)
        serializer.put_int(self.parent_order_id)

    def get_next_order_id(self):
        result = self.next_order_id
        self.next_order_id += 1
        return result
