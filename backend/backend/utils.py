import os

from fastapi import UploadFile
import psycopg2
from dotenv import load_dotenv
from typing import List
import boto3

load_dotenv()

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

s3 = boto3.client('s3', aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))


# using amazon s3

        
class S3Manager:
    def __init__(self):
        self.s3 = boto3.client('s3', aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))
        self.bucket_name = os.getenv("BUCKET_NAME")
        self.resource_uri =  os.getenv('RESOURCE_URI')
    def uploadToCloud(self, images: List[UploadFile], item_id: int, item_type: str) -> List[str]:
        uris = []
        for i, image in enumerate(images):
            link = f"{item_type}/{item_id}/{i}_{image.filename}"
            uri = self.resource_uri + link
            uris.append(uri)
            s3.upload_fileobj(image.file, self.bucket_name, link)
        return uris
    
    def deleteFromCloud(self, item_id: int, item_type: str):
        response = self.s3.list_objects_v2(Bucket=self.bucket_name, Prefix=f"{item_type}/{item_id}")
        if 'Contents' in response:
            for item in response['Contents']:
                self.s3.delete_object(Bucket=self.bucket_name, Key=item['Key'])
                
        
S3Client = S3Manager()
                               
        