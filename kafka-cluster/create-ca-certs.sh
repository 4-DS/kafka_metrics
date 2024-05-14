#!/bin/bash

set -e

export USER=$(id -u)
export GROUP=$(id -g)

rm -rf truststore
rm -rf keystore

KAFKA_HOSTNAME=localhost

docker run \
    --user $USER:$GROUP \
    -v /etc/passwd:/etc/passwd \
    -e USER=$USER \
    --rm \
    --net=host \
    -e KAFKA_HOSTNAME=$KAFKA_HOSTNAME \
    -v $PWD:/scripts \
    -w /scripts \
    --entrypoint /bin/bash \
    ibmjava:11-jdk \
    gen-ca-certs.sh
    
#\cp ca.crt ../producer/ca.crt
