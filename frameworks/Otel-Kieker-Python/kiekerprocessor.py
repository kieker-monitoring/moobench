from opentelemetry.sdk.trace import SpanProcessor
from opentelemetry import trace
from opentelemetry.trace import Span
import threading
span_registry = {}
_eoi = 0
class IncrementAttributeSpanProcessor(SpanProcessor):
	_lock = threading.Lock()

	def __init__(self):
		pass

	def on_start(self, span: Span, parent_context):
		global span_registry
		span_id = span.get_span_context().span_id
		span_registry[span_id] = span
		with self._lock:
			
			global _eoi
			_eoi+=1
			span.set_attribute("eoi",_eoi)

		
		parent_span = span.parent
		if parent_span is not None:
			# Get the attribute value from the parent span
			parent_span = span_registry[parent_span.span_id]
			current_value_ess = parent_span.attributes["ess"]
			# Get the current value of the attribute in the current span
			current_value_ess = current_value_ess+1
			# Increment the current span's attribute value
			span.set_attribute("ess",current_value_ess)
		else:
			pass

	def on_end(self, span: Span):
		pass
