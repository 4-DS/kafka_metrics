#!/bin/env python

from kafka import KafkaConsumer
from kafka.errors import KafkaError
from kafka import TopicPartition
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

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer(bootstrap_servers=[f'{kafka_ip_address}:{kafka_port}'],
                         security_protocol = "SSL",
                         ssl_context=context,
                         auto_offset_reset='earliest',
                         enable_auto_commit=True,
                         consumer_timeout_ms=1000)

assert(consumer.bootstrap_connected())

consumer.assign([TopicPartition(kafka_topic, 0)])
consumer.seek_to_beginning()

for message in consumer:
    # message value and key are raw bytes -- decode if necessary!
    # e.g., for unicode: `message.value.decode('utf-8')`
    print ("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))

print('Consumed all messages, exiting by poll timeout')
consumer.close()