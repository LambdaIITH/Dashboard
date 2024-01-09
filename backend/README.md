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

## Running the server

Once the virtual environment is activated, run the following command to start the server:

```bash
cd dashboard-learning-backend
uvicorn main:app --reload
```

The server will be available at [http://localhost:8000](http://localhost:8000). The `--reload` flag
will cause the server to restart whenever a file is changed.
