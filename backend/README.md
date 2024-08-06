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

To start the FastAPI server:

```bash
uvicorn main:app --reload
```