# How to run

## Run kafka
Run single node kafka with web ui (additional container, can be safely disbled)

```
git clone https://github.com/4-DS/kafka_metrics.git
```
```
cd kafka_metrics
cd kafka
bash run_kafka.sh
```

## Produce Messages
Run Producer example:
if in kafka:
```
cd ..
```

Then:

```
cd producer
bash run_producer.sh
```

## Consume messages
Run Consumer example:
if in kafka:
```
cd ..
```

Then:

```
cd consumer
bash run_consumer.sh
```

**To change kafka server address for producer and consumer modify env variable KAFKA_SERVER in corresponding bash launch scripts**

## How to get certs chain from kafka

openssl s_client -showcerts -verify 5 -connect ${BROKER_IP}:${BROKER_PORT}