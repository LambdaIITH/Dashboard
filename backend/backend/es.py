from elasticsearch import Elasticsearch


class ElasticsearchManager:
    def __init__(self, host="localhost", port=9200):
        self.es = Elasticsearch([{"host": host, "port": port, "scheme": "http"}])
        self.setup_indices()

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
        for index in ["losts", "founds"]:
            if not self.es.indices.exists(index=index):
                self.es.indices.create(index=index, body=settings_and_mappings)

    def add_item(self, item_id, name, description, item_type, timestamp):
        index = "losts" if item_type == "lost" else "founds"
        document = {
            "name": name,
            "id":item_id,
            "description": description,
            "timestamp": timestamp
        }
        response = self.es.index(index=index, id=item_id, document=document)
        return response

    def search_items(self, query, item_type=None, max_results=10000):
        index = "losts" if item_type == "lost" else "founds"
        search_body = {
            "query": {
                "match": {"description": query}
            },
            "size": max_results,
            "_source": ["id", "name"]  # Specify only to fetch 'id' and 'name'
        }
        response = self.es.search(index=index, body=search_body)
        return response['hits']['hits']

    def delete_item(self, doc_id, item_type):
        index = "losts" if item_type == "lost" else "founds"
        response = self.es.delete(index=index, id=doc_id)
        return response


# Example usage
if __name__ == "__main__":
    es_manager = ElasticsearchManager()
    es_manager.add_item(1, "Black Wallet", "Lost black wallet at Central Park", "lost", "2023-10-05T14:12:12")
    es_manager.add_item(2, "Set of Keys", "Found keys near River Side", "found", "2023-10-06T15:00:00")
    print(es_manager.search_items("central park", "lost"))

    # Deleting an item (assuming you know the document ID and type)
    # print(es_manager.delete_item("document_id_here", "lost"))
