from elasticsearch import Elasticsearch
import boto3
from typing import List
import os
from dotenv import load_dotenv
from fastapi import UploadFile

load_dotenv()


class ElasticsearchManager:
    def __init__(self, host="localhost", port=9200):
        elastic_password = os.getenv("ELASTIC_PASSWORD")
        elastic_username = os.getenv("ELASTIC_USERNAME")
        elastic_port = int(os.getenv("ELASTIC_PORT"))
        elastic_host = os.getenv("ELASTIC_HOST")
        
        
        self.es = Elasticsearch([{"host": elastic_host, "port": elastic_port, "scheme": "http"}], basic_auth=(elastic_username, elastic_password), request_timeout= 2)
        self.indices = ["lost", "found"]
        self.setup_indices()
        if self.works():
            print("Connected to Elastic Search Service")
        
        
    def works(self):
        return self.es.ping()
    def setup_indices(self):
        settings_and_mappings = {
            "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 0
            },
            "mappings": {
                "properties": {
                    "name": {"type": "text"},
                    "description": {"type": "text"},
                    "id":  {"type" : "integer"},
                    "timestamp": {"type": "date"}
                }
            }
        }
        for index in self.indices:
            if not self.es.indices.exists(index=index):
                self.es.indices.create(index=index, body=settings_and_mappings)

    def add_item(self, item_id : int, name: str, description : str, item_type : str, timestamp : str):
        index = "lost" if item_type == "lost" else "found"
        document = {
            "name": name,
            "id":item_id,
            "description": description,
            "timestamp": timestamp
        }
        response = self.es.index(index=index, id=item_id, document=document)
        return response

    def search_items(self, query:str,  max_results: int, item_type: str =None):
        index = "lost" if item_type == "lost" else "found"
        search_body = {
            "query": {
                "match": {"description": query},
            },
            "size": max_results,
            "_source": ["id", "name"]  # Specify only to fetch 'id' and 'name'
        }
        response = self.es.search(index=index, body=search_body)
        return response['hits']['hits']

    def delete_item(self, doc_id: int, item_type : str):
        index = "lost" if item_type == "lost" else "found"
        response = self.es.delete(index=index, id=doc_id)
        return response

class S3Manager:
    def __init__(self):
        self.s3 = boto3.client('s3', aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))
        self.bucket_name = os.getenv("BUCKET_NAME")
        self.resource_uri =  os.getenv('RESOURCE_URI')
        print("Connected to S3 Service")
    def uploadToCloud(self, images: List[UploadFile], item_id: int, item_type: str) -> List[str]:
        uris = []
        for i, image in enumerate(images):
            link = f"{item_type}/{item_id}/{i}_{image.filename}"
            uri = self.resource_uri + link
            uris.append(uri)
            self.s3.upload_fileobj(image.file, self.bucket_name, link)
        return uris
    
    def deleteFromCloud(self, item_id: int, item_type: str):
        response = self.s3.list_objects_v2(Bucket=self.bucket_name, Prefix=f"{item_type}/{item_id}")
        if 'Contents' in response:
            for item in response['Contents']:
                self.s3.delete_object(Bucket=self.bucket_name, Key=item['Key'])
                
        
        
        
# Example usage
if __name__ == "__main__":
    es_manager = ElasticsearchManager()
    es_manager.add_item(1, "Black Wallet", "Lost black wallet at Central Park", "lost", "2023-10-05T14:12:12")
    # es_manager.add_item(2, "Set of Keys", "Found keys near River Side", "found", "2023-10-06T15:00:00")
    print(es_manager.search_items("central park", 10,"lost"))

    # Deleting an item (assuming you know the document ID and type)
    # print(es_manager.delete_item(2, "found"))
