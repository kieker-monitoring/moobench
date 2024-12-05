import inspect
from monitoring.traceregistry import TraceRegistry
from monitoring.controller import SingleMonitoringController
from tools.ModuleTransformer import ModuleTransformer

### aspect.py ###
trace_reg = TraceRegistry()
is_method_or_function = lambda x: inspect.isfunction(x) or inspect.ismethod(x)
monitoring_controller = SingleMonitoringController() # Singleton

### importhookast.py ###
transformer = ModuleTransformer()