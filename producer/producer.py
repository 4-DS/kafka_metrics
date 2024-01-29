#!/bin/env python

from kafka import KafkaProducer
from kafka.errors import KafkaError
import msgpack
import logging
import json
import os

dirname = os.path.dirname(os.path.join(os.path.abspath(__file__)))

producer = KafkaProducer(bootstrap_servers=[f'{os.getenv("KAFKA_SERVER")}:9093'],
                         security_protocol = "SSL",
                         ssl_check_hostname=False,
                         ssl_cafile=os.path.join(dirname, 'ca.pem'),
                         ssl_certfile=os.path.join(dirname, 'client-signed.pem')
                         )
assert(producer.bootstrap_connected())

# Asynchronous by default
future = producer.send(os.getenv('KAFKA_TOPIC'), b'test_event_data')

# Block for 'synchronous' sends
try:
    record_metadata = future.get(timeout=10)
except KafkaError:
    # Decide what to do if produce request failed...
    logging.exception()
    pass

# Successful result returns assigned partition and offset
print(record_metadata.topic)
print(record_metadata.partition)
print(record_metadata.offset)

# produce asynchronously
for _ in range(100):
    producer.send(os.getenv('KAFKA_TOPIC'), b'msg')

def on_send_success(record_metadata):
    print(record_metadata.topic)
    print(record_metadata.partition)
    print(record_metadata.offset)

def on_send_error(excp):
    logging.error('I am an errback', exc_info=excp)
    # handle exception

# produce asynchronously with callbacks
producer.send(os.getenv('KAFKA_TOPIC'), b'raw_bytes').add_callback(on_send_success).add_errback(on_send_error)

# block until all async messages are sent
producer.flush()