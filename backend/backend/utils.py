import os

import psycopg2
from dotenv import load_dotenv

from external_services import ElasticsearchManager, S3Manager



DATABASE = os.getenv("DATABASE")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASS = os.getenv("POSTGRES_PASS")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")

try: 
    conn = psycopg2.connect(
        database=DATABASE,
        user=POSTGRES_USER,
        password=POSTGRES_PASS,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
    )
    print( "\nConnected Successfully!\n")
except:
    print("Connection Failed")

conn.autocommit = False


# using amazon s3

        

S3Client = S3Manager()
ESClient = ElasticsearchManager()
                               
        