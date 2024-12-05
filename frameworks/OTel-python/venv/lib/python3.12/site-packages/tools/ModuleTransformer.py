# -*- coding: utf-8 -*-
from ast import NodeTransformer, Name, Load

class ModuleTransformer(NodeTransformer):
    def __init__(self, empty_decorator=False):
        self.empty_decorator=empty_decorator
    def visit_FunctionDef(self, node):
        ''' Add a decorator to the function definition. 
        The decorator is placed at the very bottom to avoid TypeErrors,
        caused by other decorators '''   
        if not self.empty_decorator:
            node.decorator_list.append( Name("instrument", ctx=Load()))
        else:
            node.decorator_list.append( Name("instrument_empty", ctx=Load()))
        return node
    
