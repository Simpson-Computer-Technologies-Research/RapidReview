from firebase_admin import firestore
from functools import *
import os, json

# make it cache all the form codes and questions into a dictionary
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "firestore_secret.json"
db = firestore.AsyncClient()

_storage = {
    "form-codes":{},
    "pending-requests":{}
}

class Cache:
    # Delete a pending request
    @cache
    async def delete_request(self, user_hash:str, user:str):
        data = await self.fetch_user("pending-requests", user_hash)
        data.pop(user)
        await self.update_requests(user_hash, json.dumps(data))
    
    # Return user from cache storage collection
    @cache
    async def fetch_user(self, collection:str, user:str):
        if user not in _storage[collection]:
            _storage[collection][user] = {}
        return _storage[collection][user]

    # Update users pending requests
    @cache
    async def update_requests(self, user:str, data):
        _storage["pending-requests"][user] = json.loads(data)
        # Update the database
        document = db.collection("pending-requests").document(user)
        await document.set({"requests": json.loads(data)}, merge=False)
        
    # Fetch a dictionary from the database
    @cache
    async def fetch_user_from_database(self, collection:str, user:str):
        _doc = db.collection(collection).document(user)
        doc = await _doc.get()
        return doc.to_dict()
        
    # Check if the user has already made a request
    @cache
    async def requests_check(self, user:str, request_user:str):
        if user not in _storage["pending-requests"]:
            return True
        if request_user in _storage["pending-requests"][user]:
            _storage["pending-requests"][user].pop(request_user)
        return True
        
        
    # Update cache storage when the discord bot launches
    @cache
    async def launch(self):
        global _storage
        _storage = {
            "form-codes":{},
            "pending-requests":{}
        }
        await self.cache_form_codes()
        await self.cache_pending_requests()
        
        
    # Cache form codes
    @cache
    async def cache_form_codes(self):
        async for form_doc in db.collection(u'form-codes').stream():
            _storage["form-codes"][form_doc.id] = form_doc.to_dict()["codes"]
    
    
    # Cache pending requests
    @cache
    async def cache_pending_requests(self):
        async for request_doc in db.collection(u'pending-requests').stream():
            _storage["pending-requests"][request_doc.id] = request_doc.to_dict()["requests"]

    