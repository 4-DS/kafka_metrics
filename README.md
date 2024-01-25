# How to run POC

## Run kafka
Run single node kafka with web ui (additional container, can be safely disbled)

```
git clone https://dt-ai.gitlab.yandexcloud.net/dsml_platform/ops/kafka_poc.git
```
```
cd kafka_poc
cd kafka
docker compose -f docker-compose-single-kafka.yaml up
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