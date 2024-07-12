## Setup

This project uses [Poetry](https://python-poetry.org/) for dependency management.

```bash
pip install poetry
```

To set up the virtual environment (first time only):

```bash
poetry install
```

To activate the virtual environment:

```bash
poetry shell
```

## Using the elastic Search Container

Elastic Search container must be run before using the server.

```bash

# store all the exports from env only
export ELASTIC_PASSWORD="PASSWORD"  
export ELASTIC_USERNAME="USERNAME"
export ELASTIC_PORT=1234
export ELASTIC_HOST=localhost


sudo docker network create elastic
sudo docker run -p $ELASTIC_HOST:$ELASTIC_PORT:$ELASTIC_PORT -d --name elasticsearch --network elastic-net \\n  -e ELASTIC_PASSWORD=$ELASTIC_PASSWORD \\n  -e "discovery.type=single-node" \\n  -e "xpack.security.http.ssl.enabled=false" \\n  -e "xpack.license.self_generated.type=trial" \\n  docker.elastic.co/elasticsearch/elasticsearch:8.14.1
```
## Running the server

Once the virtual environment is activated, run the following command to start the server:

```bash
cd backend
uvicorn main:app --reload
```

if error occurs try: 
```bash
poetry install --no-root 
uvicorn main:app --reload
```

The server will be available at [http://localhost:8000](http://localhost:8000). The `--reload` flag
will cause the server to restart whenever a file is changed.
