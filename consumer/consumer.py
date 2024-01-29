#!/bin/env python

from kafka import KafkaConsumer
from kafka.errors import KafkaError
from kafka import TopicPartition
import msgpack
import logging
import json
import os

dirname = os.path.dirname(os.path.join(os.path.abspath(__file__)))

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer(bootstrap_servers=[f'{os.getenv("KAFKA_SERVER")}:9092'],
                         security_protocol = "SSL",
                         ssl_check_hostname=False,
                         ssl_cafile=os.path.join(dirname, 'ca.pem'),
                         ssl_certfile=os.path.join(dirname, 'client-signed.pem'),
                         auto_offset_reset='earliest',
                         enable_auto_commit=True,
                         consumer_timeout_ms=1000)

assert(consumer.bootstrap_connected())

consumer.assign([TopicPartition(os.getenv('KAFKA_TOPIC'), 0)])
consumer.seek_to_beginning()

for message in consumer:
    # message value and key are raw bytes -- decode if necessary!
    # e.g., for unicode: `message.value.decode('utf-8')`
    print ("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))

print('Consumed all messages, exiting by poll timeout')
consumer.close()


# consume json messages
#KafkaConsumer(value_deserializer=lambda m: json.loads(m.decode('ascii')))

# consume msgpack
#KafkaConsumer(value_deserializer=msgpack.unpackb)

# StopIteration if no message after 1sec
#KafkaConsumer(consumer_timeout_ms=1000)

# Subscribe to a regex topic pattern
#consumer = KafkaConsumer()
#consumer.subscribe(pattern='^awesome.*')

# Use multiple consumers in parallel w/ 0.9 kafka brokers
# typically you would run each on a different server / process / CPU
#consumer1 = KafkaConsumer(os.getenv('KAFKA_TOPIC'),
#                          group_id='my-group',
#                          bootstrap_servers=[f'{os.getenv("KAFKA_SERVER")}:9092'])
#consumer2 = KafkaConsumer(os.getenv('KAFKA_TOPIC'),
#                          group_id='my-group',
#                          bootstrap_servers=[f'{os.getenv("KAFKA_SERVER")}:9092'])