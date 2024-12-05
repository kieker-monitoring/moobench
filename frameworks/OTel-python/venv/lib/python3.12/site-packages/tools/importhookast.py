#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul 28 13:24:25 2022

@author: serafim
"""

from importlib.abc import Loader, MetaPathFinder
from importlib.util import spec_from_file_location
from ast import ImportFrom,  parse, alias, unparse, fix_missing_locations
import os
import tools.const as con
from tools.ModuleTransformer import ModuleTransformer



class InstrumentOnImportFinder(MetaPathFinder):

    
    ''' This class is a custom implementation of a MetaPathFinder.
    It is used to find specs for     
    '''    
    
    def __init__(self, ignore_list=[], empty = False, debug_on=False):

        self.debug_on = debug_on
        self.ignore_list = ignore_list
        self.empty = empty
        
    def find_spec(self, fullname, path, target = None):
        name = fullname.split(".")[-1]
        if path is None or path == "":
            path = [os.getcwd()]
        for e in path:
            directory = os.path.join(e, name)
            if os.path.isdir(directory):
                filename = os.path.join(directory, "__init__.py")
                spec = spec_from_file_location(fullname,
                                               filename,

                                               loader=InstLoader(filename, self.empty, self.ignore_list, self.debug_on), 
                                               submodule_search_locations=[directory])
            else:
                filename = directory + ".py"
                spec = spec_from_file_location(fullname,
                                               filename,

                                               loader=InstLoader(filename, self.empty, self.ignore_list, self.debug_on), 
                                               submodule_search_locations=None)
            
            if  os.path.exists(filename):
                return spec
            else:
                del spec 
        return None
    
    
class InstLoader(Loader):
    def __init__(self, filename, is_empty, ignore_list, debug=False ):
        self.filename = filename
        self.debug_on = debug
        self.ignore_list = ignore_list
        self.is_empty = is_empty
        

    def create_module(self, spec):
        return None 

    def exec_module(self, module):

       
       ex=["tools.aspect","monitoring.record",
           "monitoring.record.trace",
           "monitoring.record.trace.operation",
           "monitoring.record.trace.operation.operationevent",
           "monitoring.traceregistry",
           "monitoring.record.trace.tracemetadata"
          ]

       # Read module source code
       with open(self.filename) as f:
           data = f.read()
       # If the module should not be instrumented
       # execute it normally
       if module.__name__ in self.ignore_list or  module.__name__ in ex: 
          exec(data, vars(module))
          return
       # parse and inject import of tools.aspect
       node = parse(data)
       if not self.is_empty:
           import_node = ImportFrom(module="tools.aspect", names=[alias(name="instrument")], level=0)
       else:
           import_node = ImportFrom(module="tools.aspect", names=[alias(name="instrument_empty")], level=0)
       
       counter = 0
       index = 0
       for i in node.body:
           index += 1
           if isinstance(i, ImportFrom):
              if i.module == "__future__":
                  counter = index
       node.body.insert(counter,import_node) 
       
       # Add @instrument annotation
       if not self.is_empty:
           transformer = ModuleTransformer()
       else:
           transformer = ModuleTransformer(True)
       node = transformer.visit(node)
       fix_missing_locations(node)
       data = unparse(node)

       try:  
         if self.debug_on:
             # TODO: create log file o.s.
             print(module.__name__)
         exec(data, vars(module))
       
       except:
           # TODO: Meaningfull exeception handling if any needed
           pass
          
          

    
    
    
