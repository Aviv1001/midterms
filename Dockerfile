FROM python:3.12-slim

RUN pip install --no-cache-dir poetry && \
    poetry config virtualenvs.create false

WORKDIR /app

COPY pyproject.toml ./
RUN poetry install --no-root

COPY app.py ./
COPY templates ./templates

RUN useradd --create-home app
USER app

EXPOSE 5000

CMD ["python", "app.py"]
