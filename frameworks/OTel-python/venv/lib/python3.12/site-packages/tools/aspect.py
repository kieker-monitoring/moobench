import inspect
import types
import decorator
import sys

from monitoring.record.trace.operation.operationevent import (BeforeOperationEvent,
                                                              AfterOperationEvent, 
                                                              AfterOperationFailedEvent, 
                                                              )

import tools.const as con



@decorator.decorator
def instrument_v1(func, *args, **kwargs):
    # before routine
    trace = con.trace_reg.get_trace()
    new_trace = trace is None
    if new_trace:
        trace = con.trace_reg.register_trace()      
        con.monitoring_controller.new_monitoring_record(trace)
        
    # before routine
    trace_id = trace.trace_id
    func_module = func.__module__
    func_name = func.__name__
    class_signature = func.__qualname__.split(".", 1)[0]
    qualname = (func_module if class_signature == func_name else
                f'{func_module}.{class_signature}')
    
    con.monitoring_controller.new_monitoring_record(BeforeOperationEvent(
           con.monitoring_controller.time_source_controller.get_time(), trace_id, 
           trace.get_next_order_id(), func_name, qualname))
    
    try:
            result = func(*args, **kwargs)

    except Exception as e:
        # failed routine
       
        con.monitoring_controller.new_monitoring_record(
            AfterOperationFailedEvent(
                    con.monitoring_controller.time_source_controller.get_time(),
                                      trace_id,
                                      trace.get_next_order_id(),
                                      func_name,
                                      qualname,
                                      repr(e)))
        raise e
    finally:
        if new_trace:
            con.trace_reg.unregister_trace()

    # after routine
    
    con.monitoring_controller.new_monitoring_record(AfterOperationEvent(
        con.monitoring_controller.time_source_controller.get_time(),
        trace_id,
        trace.get_next_order_id(),
        func_name,
        qualname))
   
    return result


def instrument_empty(func):
    def _instrument(*args, **kwargs):
        try:
            result = func(*args, **kwargs)
        except:
            raise
        return result
    _instrument.__name__ = func.__name__
    _instrument.__doc__ = func.__doc__
    _instrument.__wrapped__ = func
    _instrument.__signature__ = inspect.signature(func)
    _instrument.__qualname__ = func.__qualname__
    return _instrument



def instrument(func):
 def _instrument( *args, **kwargs):
    # before routine
    trace = con.trace_reg.get_trace()
    new_trace = trace is None
    if new_trace:
        trace = con.trace_reg.register_trace()      
        con.monitoring_controller.new_monitoring_record(trace)
        
    # before routine
    trace_id = trace.trace_id
    func_module = func.__module__
    func_name = func.__name__
    class_signature = func.__qualname__.split(".", 1)[0]
    qualname = (func_module if class_signature == func_name else
                f'{func_module}.{class_signature}')
    
    con.monitoring_controller.new_monitoring_record(BeforeOperationEvent(
           con.monitoring_controller.time_source_controller.get_time(), 
           trace_id, trace.get_next_order_id(), func_name, qualname))
    
    try:
            result = func(*args, **kwargs)
            
    except Exception as e:
        # failed routine
       
        con.monitoring_controller.new_monitoring_record(
            AfterOperationFailedEvent(
                con.monitoring_controller.time_source_controller.get_time(), 
                                      trace_id,
                                      trace.get_next_order_id(),
                                      func_name,
                                      qualname,
                                      repr(e)))
        raise e
    finally:
        if new_trace:
            con.trace_reg.unregister_trace()

    # after routine
    
    con.monitoring_controller.new_monitoring_record(AfterOperationEvent(
        con.monitoring_controller.time_source_controller.get_time(),
        trace_id,
        trace.get_next_order_id(),
        func_name,
        qualname))
   
    return result

 _instrument.__name__ = func.__name__
 _instrument.__doc__ = func.__doc__
 _instrument.__wrapped__ = func
 _instrument.__signature__ = inspect.signature(func)
 _instrument.__qualname__ = func.__qualname__
 return _instrument

def decorate_members(mod, empty = False):
    '''
    Decorates methods and global functions of the given module
    '''
    if not empty:
        inst = instrument_v1
    else:
        inst = instrument_empty
    #class_redecorator = redecorate(instrument)

    # Decorate classes
    for name, member in inspect.getmembers(mod, inspect.isclass):
        if(member.__module__ == mod.__spec__.name):  # skip members of imported modules
            for k, v in inspect.getmembers(member, con.is_method_or_function):
                try:
                  
                    if isinstance(member.__dict__[k], classmethod):
                        funcobj = member.__dict__[k].__func__
                        setattr(member, k, classmethod(inst(funcobj)))
                    elif isinstance(member.__dict__[k], staticmethod):
                        funcobj = member.__dict__[k].__func__
                        setattr(member, k, staticmethod(inst(funcobj)))
                        pass
                    elif isinstance(member.__dict__[k], property):
                        funcobj = member.__dict__[k].__func__
                        setattr(member, k, property(inst(funcobj)))
                        pass
                    elif isinstance(member.__dict__[k], types.FunctionType):
                        setattr(member, k, inst(v))
                        pass
                except KeyError:
                    # inspect.getmembers() lists also methods from inherited
                    # classes. __dict__ contains information about methods that
                    # are defined in the given class. So, do nothing 
                    # and
                    continue
                    
    for name, member in inspect.getmembers(mod, inspect.isfunction):
        if(member.__module__ == mod.__spec__.name):
            mod.__dict__[name] = inst(member)
    
    

# 


@decorator.decorator
def decorate_find_spec(find_spec, module_name=None,exclusion=None, *args, **kwargs):
    result = find_spec(*args, **kwargs)
    if result is None:
        return result

    try:
        if "exec_module" in dir(result.loader):
            exec_module = getattr(result.loader, "exec_module")
            if isinstance(exec_module, classmethod):
                funcobj = exec_module.__func__
                setattr(result.loader, "exec_module",classmethod(decorate_exec_module(funcobj, module_name, exclusion)))
            elif isinstance(exec_module, types.MethodType):
                funcobj = exec_module.__func__
                setattr(result.loader, "exec_module", types.MethodType(decorate_exec_module(funcobj, module_name, exclusion), result.loader))
            else:
                setattr(result.loader, "exec_module", decorate_exec_module(exec_module, module_name, exclusion))
    except AssertionError:
        return result
    return result

@decorator.decorator
def decorate_exec_module(exec_module, module_name=None, exclusion=None, *args, **kwargs):
    exec_module(*args, **kwargs)
    if module_name in args[1].__spec__.name:
        decorate_members(sys.modules[args[1].__spec__.name])
## Not sure if the return statement is important ##
#    if exclusion in args[1].__spec__.name or args[1].__spec__.name in exclusion:
#        return
#    elif module_name in args[1].__spec__.name:
#        decorate_members(sys.modules[args[1].__spec__.name])