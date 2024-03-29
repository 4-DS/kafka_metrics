#!/bin/bash

set -e

export USER=$(id -u)
export GROUP=$(id -g)

read -p "Enter path to store kafka data [default = %current_directory%/data]: " kafkaDataFolder
read -p "Enter topic name to create [default = example_topic]: " kafkaTopicName
read -p "Enter VM IP for producer/consumer connections [default = 127.0.0.1]: " kafkaExternalIp

KAFKA_DATA_FOLDER="${kafkaDataFolder:-$PWD/data}"
KAFKA_TOPIC_NAME="${kafkaTopicName:-example_topic}"
KAFKA_EXTERNAL_IP="${kafkaExternalIp:-127.0.0.1}"

. create-certs.sh

mkdir -p $KAFKA_DATA_FOLDER
docker rm -f kafka-server || echo kafka-server doesnt exist

docker run -d \
    --restart=always \
    --name kafka-server \
    --hostname=localhost \
    -p 9092:9092 \
    -p 9094:9094 \
    -v "$PWD/keystore/kafka.keystore.jks":"/opt/bitnami/kafka/config/certs/kafka.keystore.jks":ro \
    -v "$PWD/truststore/kafka.truststore.jks":"/opt/bitnami/kafka/config/certs/kafka.truststore.jks":ro \
    -v "$PWD/client.ssl.conf":"/opt/bitnami/client.ssl.conf":ro \
    -v "kafka_data_volume":"/bitnami/kafka" \
    -e KAFKA_CFG_NODE_ID=0 \
    -e KAFKA_CFG_PROCESS_ROLES=broker,controller \
    -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    -e KAFKA_CFG_LISTENERS=SSL://:9092,CONTROLLER://:9093,EXTERNAL://:9094 \
    -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:SSL,SSL:SSL,EXTERNAL:SSL \
    -e KAFKA_CFG_ADVERTISED_LISTENERS=SSL://:9092,EXTERNAL://${KAFKA_EXTERNAL_IP}:9094 \
    -e KAFKA_CFG_INTER_BROKER_LISTENER_NAME=SSL \
    -e KAFKA_TLS_CLIENT_AUTH=none \
    -e KAFKA_CERTIFICATE_PASSWORD=datapass \
    -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@:9093 \
    -e KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE='false' \
    bitnami/kafka:latest

# wait for kafka to start and list topics
docker exec kafka-server /opt/bitnami/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 --command-config /opt/bitnami/client.ssl.conf > /dev/null 2>&1

# create a topic with a name provided by user
docker exec kafka-server /opt/bitnami/kafka/bin/kafka-topics.sh --create --topic "$KAFKA_TOPIC_NAME" --bootstrap-server localhost:9092 --command-config "/opt/bitnami/client.ssl.conf"

docker logs -f kafka-server
