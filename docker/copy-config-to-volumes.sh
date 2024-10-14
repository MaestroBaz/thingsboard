#!/bin/bash

# Load environment variables from .env file
source .env

# Array of services and their respective config directories and volumes
services=(
  "tb-core1:tb-node:${TB_CONFIG_VOLUME}:thingsboard.conf"
  "tb-core2:tb-node:${TB_CONFIG_VOLUME}:thingsboard.conf"
  "tb-rule-engine1:tb-node:${TB_CONFIG_VOLUME}:thingsboard.conf"
  "tb-rule-engine2:tb-node:${TB_CONFIG_VOLUME}:thingsboard.conf"
  "tb-mqtt-transport1:tb-transports/mqtt:${TB_MQTT_TRANSPORT_CONFIG_VOLUME}:tb-mqtt-transport.conf"
  "tb-mqtt-transport2:tb-transports/mqtt:${TB_MQTT_TRANSPORT_CONFIG_VOLUME}:tb-mqtt-transport.conf"
  "tb-http-transport1:tb-transports/http:${TB_HTTP_TRANSPORT_CONFIG_VOLUME}:tb-http-transport.conf"
  "tb-http-transport2:tb-transports/http:${TB_HTTP_TRANSPORT_CONFIG_VOLUME}:tb-http-transport.conf"
  "tb-coap-transport:tb-transports/coap:${TB_COAP_TRANSPORT_CONFIG_VOLUME}:tb-coap-transport.conf"
  "tb-lwm2m-transport:tb-transports/lwm2m:${TB_LWM2M_TRANSPORT_CONFIG_VOLUME}:tb-lwm2m-transport.conf"
  "tb-snmp-transport:tb-transports/snmp:${TB_SNMP_TRANSPORT_CONFIG_VOLUME}:tb-snmp-transport.conf"
  "tb-vc-executor1:tb-vc-executor:${TB_VC_EXECUTOR_CONFIG_VOLUME}:tb-vc-executor.conf"
  "tb-vc-executor2:tb-vc-executor:${TB_VC_EXECUTOR_CONFIG_VOLUME}:tb-vc-executor.conf"
)

# Loop over each service and copy the files to the respective volume
for entry in "${services[@]}"; do
  # Split the entry into service, config directory, volume, and config file
  service_name="${entry%%:*}"
  rest="${entry#*:}"
  config_dir="${rest%%:*}/conf"
  volume_name="${rest#*:}"
  volume_name="${volume_name%%:*}"
  config_file="${rest##*:}"

  # Check if the config directory and volume name are set
  if [ -d "$config_dir" ] && [ -n "$volume_name" ]; then
    echo "Copying configuration for $service_name from $config_dir to $volume_name..."

    # Copy logback.xml and the respective .conf file to the Docker volume
    docker run --rm \
      -v "${volume_name}:/config" \
      -v "$(pwd)/${config_dir}:/source_config" \
      busybox sh -c "cp /source_config/logback.xml /config/ && cp /source_config/${config_file} /config/"

    echo "Configuration copied for $service_name."
  else
    echo "Configuration directory or volume name for $service_name not found. Skipping..."
  fi
done

echo "All configurations copied successfully."