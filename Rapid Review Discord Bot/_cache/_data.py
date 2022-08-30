from functools import *

_code_storage = {}

class Data:
    @cache
    async def check(self, user_hash:str):
        if user_hash in _code_storage:
            return _code_storage[user_hash]
        return ""
    
    @cache
    async def update(self, user_hash:str, channel:int):
        _code_storage[user_hash] = channel
    
    @cache
    async def get(self, user_hash):
      return _code_storage[user_hash]
    
    @cache
    async def delete(self, user_hash):
        del _code_storage[user_hash]