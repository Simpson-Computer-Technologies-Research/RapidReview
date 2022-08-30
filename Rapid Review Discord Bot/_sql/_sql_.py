from contextlib import closing
from functools import *
import mysql.connector

# CONNECT TO THE "MySQL Database" FUNCTION
def _connect():
    return mysql.connector.connect(
        host="host",
        user="admin",
        passwd="password",
        database="main"
    )
db = _connect()

class SQL_CLASS():
    def __init__(self):
        with closing(db.cursor()) as cur:
            pass
            #cur.execute(f"DROP TABLE connections")
            #cur.execute("CREATE TABLE connections (user_hash VARCHAR(160), user_id BIGINT, user_name VARCHAR(40), id int PRIMARY KEY AUTO_INCREMENT)")


    # // CHECK IF A VALUE IN A TABLE EXISTS
    @cache
    async def exists(self, command):
        global db
        try:
            with closing(db.cursor(buffered=True)) as cur:
                cur.execute(command)
                if cur.fetchone() is None:
                    return False  # // Doesn't exist
                return True  # // Does exist
        except mysql.connector.Error:
            db.close()
            db = _connect()
            
    # // RETURNS A SINGLE LIST FROM THE SELECTED TABLE
    @cache
    async def select(self, command):
        global db
        try:
            with closing(db.cursor()) as cur:
                if await self.exists(command):
                    cur.execute(command)
                    return list(cur.fetchone())
                return None
        except mysql.connector.Error:
            db.close()
            db = _connect()

    # // EXECUTE A SEPERATE COMMAND
    @cache
    async def execute(self, command):
        global db
        try:
            with closing(db.cursor()) as cur:
                cur.execute(command)
                return db.commit()
        except mysql.connector.Error:
            db.close()
            db = _connect()
