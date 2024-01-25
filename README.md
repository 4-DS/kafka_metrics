# How to run POC

Run single node kafka with web ui (additional container, can be safely disbled)

```
git clone https://dt-ai.gitlab.yandexcloud.net/dsml_platform/ops/kafka_poc.git
```
```
cd kafka_poc
cd kafka
docker compose -f docker-compose-single-kafka.yaml up
```

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
