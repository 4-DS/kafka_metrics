#!/bin/env python

from kafka import KafkaProducer
from kafka.errors import KafkaError
import msgpack
import logging
import json
import os
import ssl

kafka_ip_address = input("Enter kafka server IP address [default = localhost]: ")
if not kafka_ip_address:
    kafka_ip_address = 'localhost'

kafka_port = input("Enter kafka server port [default = 9094]: ")
if not kafka_port:
    kafka_port = '9094'

kafka_topic = input("Enter kafka topic name to send data to [default = example_topic]: ")
if not kafka_topic:
    kafka_topic = 'example_topic'

dirname = os.path.dirname(os.path.join(os.path.abspath(__file__)))

context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

producer = KafkaProducer(bootstrap_servers=[f'{kafka_ip_address}:{kafka_port}'],
                         security_protocol = "SSL",
                         ssl_context=context
                         )

assert(producer.bootstrap_connected())

print(producer.partitions_for(kafka_topic))

# Asynchronous by default
future = producer.send(kafka_topic, b'test_event_data1')

# Block for 'synchronous' sends
try:
    record_metadata = future.get(timeout=1000)
except KafkaError:
    # Decide what to do if produce request failed...
    logging.exception('')

# Successful result returns assigned partition and offset
print(record_metadata.topic)
print(record_metadata.partition)
print(record_metadata.offset)

# produce asynchronously
for _ in range(100):
    producer.send(kafka_topic, b'msg')

def on_send_success(record_metadata):
    print(record_metadata.topic)
    print(record_metadata.partition)
    print(record_metadata.offset)

def on_send_error(excp):
    logging.error('I am an errback', exc_info=excp)
    # handle exception

# produce asynchronously with callbacks
producer.send(kafka_topic, b'raw_bytes').add_callback(on_send_success).add_errback(on_send_error)

# block until all async messages are sent
producer.flush()
producer.close()
