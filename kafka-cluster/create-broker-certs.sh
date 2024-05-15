#!/bin/bash

set -e

export USER=$(id -u)
export GROUP=$(id -g)

KAFKA_HOSTNAME=localhost
KAFKA_REMOTE_ADDRESS=$1

rm -rf "${KAFKA_REMOTE_ADDRESS}/keystore"

docker run \
    --user $USER:$GROUP \
    -v /etc/passwd:/etc/passwd \
    -e USER=$USER \
    --rm \
    -e KAFKA_REMOTE_ADDRESS=$KAFKA_REMOTE_ADDRESS \
    -e KAFKA_HOSTNAME=$KAFKA_HOSTNAME \
    --net=host \
    -v $PWD:/scripts \
    -w /scripts \
    --entrypoint /bin/bash \
    ibmjava:11-jdk \
    gen-broker-certs.sh
    
#\cp ca.crt ../producer/ca.crt
