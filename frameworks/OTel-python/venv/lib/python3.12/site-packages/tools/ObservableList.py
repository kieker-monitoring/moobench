class ObservableList(list):
    def __init__(self):
        self.super(self, list)
        
from collections import UserList
class Foo(list):
    def __init__(self, args):
        list.__init__(self, args)
    def __setitem__(self,index, item):
        print(f'added {item} at {index}')
        list.__setitem__(self,index, item)
    def __add__(self, other):
       print("ad")
       return list.__add__(self, other)

def mydunc(list, other):
    if list is
import inspect

for k,v in inspect.getmembers(list):
    if k == "__add__":
        list.setattr(k, myfunc)   

bar = Foo(list())
bar.append(4)
print(bar)
bar[0]=7
print(type(bar))
bar = bar + [0,1]
print(type(bar))
print(bar)

