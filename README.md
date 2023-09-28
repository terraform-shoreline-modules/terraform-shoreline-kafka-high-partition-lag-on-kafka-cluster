
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High Partition Lag on Kafka Cluster
---

This incident type refers to an issue with a Kafka cluster where one or more partitions are experiencing high lag. Lag is the difference between the latest message produced to a partition and the latest message consumed from that partition. When a partition lags behind, it means that messages are not being consumed as quickly as they are being produced. This can lead to a backlog of messages and potential data loss if not addressed. The incident description suggests checking for hot partitions, which are partitions that receive a disproportionate amount of traffic compared to others. Identifying and resolving high partition lag is critical to ensure the stability and reliability of a Kafka cluster.

### Parameters
```shell
export ZOOKEEPER_PORT="PLACEHOLDER"

export ZOOKEEPER_HOSTNAME="PLACEHOLDER"

export CONSUMER_GROUP_NAME="PLACEHOLDER"

export KAFKA_BROKER_HOSTNAME="PLACEHOLDER"

export KAFKA_BROKER_PORT="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export PARTITION_NUMBER="PLACEHOLDER"

export KAFKA_BOOTSTRAP_SERVER="PLACEHOLDER"

export PATH_TO_KAFKA_HOME="PLACEHOLDER"
```

## Debug

### List all topics and their partition count
```shell
kafka-topics.sh --zookeeper ${ZOOKEEPER_HOSTNAME}:${ZOOKEEPER_PORT} --list | while read topic; do echo "$topic: $(kafka-topics.sh --zookeeper ${ZOOKEEPER_HOSTNAME}:${ZOOKEEPER_PORT} --describe --topic $topic | grep -c '^partition') partitions"; done
```

### List the partition lag for a specific consumer group
```shell
kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BROKER_HOSTNAME}:${KAFKA_BROKER_PORT} --describe --group ${CONSUMER_GROUP_NAME}
```

### List the current offset for a specific partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${KAFKA_BROKER_HOSTNAME}:${KAFKA_BROKER_PORT} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -1
```

### List the end offset for a specific partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${KAFKA_BROKER_HOSTNAME}:${KAFKA_BROKER_PORT} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -2
```

### List the number of messages in a specific partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${KAFKA_BROKER_HOSTNAME}:${KAFKA_BROKER_PORT} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -1 | awk -F ":" '{print $3}' | tail -1
```

### List the number of messages consumed by a specific consumer group for a specific topic
```shell
kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BROKER_HOSTNAME}:${KAFKA_BROKER_PORT} --describe --group ${CONSUMER_GROUP_NAME} | grep ${TOPIC_NAME} | awk '{print $5}'
```

## Repair

### Increase the number of consumer instances for the high-traffic partitions to reduce the lag. This can be done by adding more consumers to the consumer group or creating a new group.
```shell


#!/bin/bash



# Set variables

KAFKA_HOME=${PATH_TO_KAFKA_HOME}

TOPIC=${TOPIC_NAME}

GROUP=${CONSUMER_GROUP_NAME}



# Increase consumer instances

$KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVER} --topic $TOPIC --group $GROUP --describe | awk '{print $2}' | tail -n +3 | xargs -I {} $KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVER} --topic $TOPIC --group $GROUP --reset-offsets --to-latest --execute --partitions {}



echo "Increased consumer instances for $TOPIC in consumer group $GROUP"


```