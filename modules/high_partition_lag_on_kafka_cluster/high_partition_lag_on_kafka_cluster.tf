resource "shoreline_notebook" "high_partition_lag_on_kafka_cluster" {
  name       = "high_partition_lag_on_kafka_cluster"
  data       = file("${path.module}/data/high_partition_lag_on_kafka_cluster.json")
  depends_on = [shoreline_action.invoke_consumer_instance_increase]
}

resource "shoreline_file" "consumer_instance_increase" {
  name             = "consumer_instance_increase"
  input_file       = "${path.module}/data/consumer_instance_increase.sh"
  md5              = filemd5("${path.module}/data/consumer_instance_increase.sh")
  description      = "Increase the number of consumer instances for the high-traffic partitions to reduce the lag. This can be done by adding more consumers to the consumer group or creating a new group."
  destination_path = "/agent/scripts/consumer_instance_increase.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_consumer_instance_increase" {
  name        = "invoke_consumer_instance_increase"
  description = "Increase the number of consumer instances for the high-traffic partitions to reduce the lag. This can be done by adding more consumers to the consumer group or creating a new group."
  command     = "`chmod +x /agent/scripts/consumer_instance_increase.sh && /agent/scripts/consumer_instance_increase.sh`"
  params      = ["TOPIC_NAME","KAFKA_BOOTSTRAP_SERVER","PATH_TO_KAFKA_HOME","CONSUMER_GROUP_NAME"]
  file_deps   = ["consumer_instance_increase"]
  enabled     = true
  depends_on  = [shoreline_file.consumer_instance_increase]
}

