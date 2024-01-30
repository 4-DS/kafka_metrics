#!/bin/bash

set -e

docker run \
    --rm \
    -v ./scripts:/scripts \
    -w /scripts \
    --entrypoint /bin/bash \
    ibmjava:11-jdk \
    kafka-generate-ssl-automatic.sh

mv scripts/keystore/kafka.keystore.jks secrets/kafka.keystore.jks
mv scripts/truststore/kafka.truststore.jks secrets/kafka.truststore.jks

rm -rf client_cert
mkdir client_cert
mv -f scripts/client.pem client_cert/client.pem
mv -f scripts/client.key client_cert/client.key
mv -f scripts/ca_root.pem client_cert/ca_root.pem

cp -f client_cert/client.pem ../consumer/client.pem
cp -f client_cert/client.key ../consumer/client.key
cp -f client_cert/ca_root.pem ../consumer/ca_root.pem

cp -f client_cert/client.pem ../producer/client.pem
cp -f client_cert/client.key ../producer/client.key
cp -f client_cert/ca_root.pem ../producer/ca_root.pem

rm -rf scripts/keystore
rm -rf scripts/truststore

# start kafka server
docker compose -f docker-compose-single-kafka-ssl.yaml up