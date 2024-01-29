#!/bin/bash

set -e

KAFKA_TOPIC="example_topic" KAFKA_SERVER="kafka1" python3 ./consumer.py