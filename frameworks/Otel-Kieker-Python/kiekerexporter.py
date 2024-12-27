import socket
import threading
from struct import pack
from opentelemetry.sdk.trace import Span
from opentelemetry.sdk.trace.export import SpanExporter
from monitoring.fileregistry import WriterRegistry
from monitoring.serialization import BinarySerializer
from monitoring.controller import TimeStamp
from opentelemetry.sdk.trace.export import SpanExporter, SpanExportResult
from datetime import datetime, timezone
lock = threading.Lock()
time = TimeStamp()

class KiekerTcpExporter(SpanExporter):
		
	def __init__(self, host="127.0.0.1", port=5678):
		self.host = host
		self.port = port
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.sock.connect_ex((self.host, self.port))
		self.writer_registry = WriterRegistry(self)
		self.serializer = BinarySerializer([], self.writer_registry)
		self.trace_dict = {}
		self.current_id = 1
		self.span_dict={}
		self.current_span_id = 1
		self.list_bytes = []
	
	def export(self, spans):
		for span in spans:
			if span.name =="Foo":
				self.send_default_0(span)
		concatenated = b"".join(self.list_bytes)
		self.list_bytes= []
		try:
			self.sock.sendall(concatenated)
		except Exception as e:
			print(repr(e))
		return SpanExportResult.SUCCESS

	def on_new_registry_entry(self, value, idee):
		# int - id, int-length, bytesequences
		# encode value in utf-8 and pack it with the id
		# value should be always a string
		v_encode = str(value).encode('utf-8')
		format_string = f'!iii{len(v_encode)}s'
		result = pack(format_string, -1, idee, len(v_encode), v_encode)
		try:
			self.sock.sendall(result)
		except Exception as e:
			print(repr(e))  # TODO: better exception handling

	
	
	def send_default_0(self, span: Span):
		#fetch record name
		lock.acquire()
		record_class_name = "kieker.common.record.controlflow.OperationExecutionRecord"
		self.writer_registry.register(record_class_name)
		self.serializer.put_string(record_class_name)
		self.serializer.put_long(time.get_time())
		self.serializer.put_string(span.attributes["operation_signature"])
		self.serializer.put_string(span.attributes["session_id"])
		self.serializer.put_long(self.get_trace_id(span.get_span_context().trace_id))
		self.serializer.put_long(int(span.start_time))
		self.serializer.put_long(int(span.end_time))
		self.serializer.put_string(span.attributes["hostname"])
		self.serializer.put_int(span.attributes["eoi"])
		self.serializer.put_int(span.attributes["ess"])
		lock.release()
		binarized_record = self.serializer.pack()
		# try to send
		try:
			self.list_bytes.append(binarized_record)
		except Exception as e:
			# TODO: Better exception handling for tcp
			print(repr(e))
								
	
	def get_trace_id(self, trace_id):
	       if trace_id not in self.trace_dict:
	           self.trace_dict[trace_id] = self.current_id
	           self.current_id += 1
	       return self.trace_dict[trace_id]
	
	def get_span_id(self, span_id):
	       if span_id not in self.span_dict:
	           self.span_dict[span_id] = self.current_span_id
	           self.current_span_id += 1
	       return self.span_dict[span_id]

