# -*- coding: utf-8 -*-

class WriterRegistry:
    
    def __init__(self, listener):
        self.storage = {}
        self.id = 0
        self.next_id = 0
        self.listener = listener
        

    def get_id(self, value):
        try:
            value_id = self.storage[value]
            return value_id
        except:
            self.register(value)
            return self.storage[value]
       
        
    def register(self, value):
        if value not in self.storage:
            _id = self.next_id + 1
            self.next_id += 1
            self.storage.update({value: _id})
            self.listener.on_new_registry_entry(value, _id)

