import importlib
import sys
from tools.aspect import decorate_members

#sys.meta_path = MyLIst(sys.MetaPath)
class PostImportFinder:

    def __init__(self,  param, exclusions, empty=False):
        self._skip=set()
        self.param = param
        self. exclusions = exclusions
        self.empty =empty
    
    def find_module(self, fullname, path = None):
        if fullname in self._skip:
            return None
        self._skip.add(fullname)
        return PostImportLoader(self, self.param, self.exclusions, self.empty)


class PostImportLoader:
    def __init__(self, finder, param, exclusions, empty):
        self._finder = finder
        self.param = param
        self.exclusions = exclusions
        self.empty = empty
    
    def load_module(self, fullname):
        importlib.import_module(fullname)
        module = sys.modules[fullname]
        if self.param.search(fullname) is not None :

           # for ex in self.exclusions:
            #    if ex.match(fullname):
             #       return
            decorate_members(module, self.empty)
        self._finder._skip.remove(fullname)
        return module
