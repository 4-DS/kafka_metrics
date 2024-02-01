docker rm -f kafka-server || echo kafka-server doesnt exist


docker run -d --name kafka-server --hostname=localhost \
     -p 9092:9092 -p 9094:9094 \
    -v "$PWD/keystore/kafka.keystore.jks":"/opt/bitnami/kafka/config/certs/kafka.keystore.jks":ro \
    -v "$PWD/truststore/kafka.truststore.jks":"/opt/bitnami/kafka/config/certs/kafka.truststore.jks":ro \
    -v "$PWD/server.properties":"/opt/bitnami/kafka/config/kraft/server.properties" \
    -e KAFKA_CFG_NODE_ID=0 \
    -e KAFKA_CFG_PROCESS_ROLES=broker,controller \
    -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    -e KAFKA_CFG_LISTENERS=SSL://:9092,CONTROLLER://:9093 \
    -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:SSL,SSL:SSL \
    -e KAFKA_CFG_ADVERTISED_LISTENERS=SSL://:9092 \
    -e KAFKA_CFG_INTER_BROKER_LISTENER_NAME=SSL \
    -e KAFKA_TLS_CLIENT_AUTH=none \
    -e KAFKA_CERTIFICATE_PASSWORD=datapass \
    -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@:9093 \
    bitnami/kafka:latest
docker logs -f kafka-server
