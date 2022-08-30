from functools import *
import time, hashlib

# /////////////////////////////
# // THIS IS VERY UNFINISHED //
# /////////////////////////////

hex_list = {
    "1": 19, "2": 12, "3": 44, "4": 24, "5": 12, "6": 35, "7": 85, "8": 12,
    "0": 54, "a": 9, "b": 48, "c": 64, "d": 99, "e": 11, "f": 45, "g": 63,
    "h": 47, "i": 35, "j": 38, "k": 10, "l": 97, "m": 36, "n": 26, "o": 53,
    "p": 8, "q": 39, "r": 77, "s": 59, "t": 36, "u": 31, "v": 47, "w": 95,
    "x": 36, "y": 35, "z": 93, "9": 40,
  }

class Auth:
    @cache
    async def encrypt(self, data):
        user = "username"
        password = "password"
        return self.encode_sha256(
            self.encode_sha256(user) + self.encode_sha256(data+str(int(time.time()))) + self.encode_sha256(password)
        )
    
    @cache
    def encode_sha256(self, data):
        return hashlib.sha256(data.encode('utf-8')).hexdigest()
    
    @cache
    def encode_sha1(self, data):
        return hashlib.sha256(data.encode('utf-8')).hexdigest()
    
    @cache
    async def get_confirmation_code(self, user_hash:str, time:int):
        user_time_hash = hashlib.sha1((user_hash+str(time)).encode()).hexdigest()
        code = 0
        for n in user_time_hash:
            code += hex_list[n] * hex_list[user_time_hash[0]]
        return code
    
    @cache
    async def check_confirmation_code(self, user_hash:str, code:str):
        _time = int(time.time()/60)
        if await self.get_confirmation_code(user_hash, _time) == int(code):
            return True