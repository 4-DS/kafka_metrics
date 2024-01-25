FROM python:3.10-slim-bookworm

ADD requirements.txt /requirements.txt
RUN mkdir -p /kafka && \
    python -m pip install --no-cache-dir -r /requirements.txt

WORKDIR /kafka