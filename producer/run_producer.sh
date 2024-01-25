#!/bin/bash

set -e

docker build . -t local/kafka_producer_poc:latest
docker run -it --rm -v $(pwd):/kafka --name kafka_poc_producer -w /kafka --network "kafka_default" -e KAFKA_TOPIC="example_topic" -e KAFKA_SERVER="kafka1" local/kafka_producer_poc:latest ./producer.py