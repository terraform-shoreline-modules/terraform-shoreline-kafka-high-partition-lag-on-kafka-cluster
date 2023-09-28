

#!/bin/bash



# Set variables

KAFKA_HOME=${PATH_TO_KAFKA_HOME}

TOPIC=${TOPIC_NAME}

GROUP=${CONSUMER_GROUP_NAME}



# Increase consumer instances

$KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVER} --topic $TOPIC --group $GROUP --describe | awk '{print $2}' | tail -n +3 | xargs -I {} $KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVER} --topic $TOPIC --group $GROUP --reset-offsets --to-latest --execute --partitions {}



echo "Increased consumer instances for $TOPIC in consumer group $GROUP"