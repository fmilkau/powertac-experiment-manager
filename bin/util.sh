#!/usr/bin/env bash

function em_compose_command() {
  if ! [ -x "$(command -v docker)" ]; then
    echo 'Error: docker command is not available.' >&2
    exit 1
  fi
  compose_command="docker-compose"
  if ! [ -x "$(command -v docker-compose)" ]; then
    compose_command="docker compose"
  fi
  if ! $compose_command > /dev/null 2>&1; then
    echo "ERROR: docker compose command '$compose_command' not available" >&2
    exit 1
  fi
  echo "$compose_command"
}

function em_host_ip() {
  ips=$(hostname -I)
  ips=( $ips )
  echo "${ips[0]}"
}

function em_host() {
    domain=$(hostname -d)
    if [ -n "$domain" ]; then
      echo "$domain"
      else
        em_host_ip
    fi
}

function em_write_env() {
  target="$1"
  em_root="$2"
  web_client_port="$3"
  orchestrator_port="$4"
  weather_server_port="$5"
  orchestrator_db_pass="$6"
  weather_db_pass="$7"
  host_ip="$8"

template="# auto-generated file

HOST_IP=${host_ip}

WEB_CLIENT_VERSION=latest
WEB_CLIENT_HOST_PORT=${web_client_port}

ORCHESTRATOR_VERSION=latest
ORCHESTRATOR_HOST_PORT=${orchestrator_port}
ORCHESTRATOR_ROOT_PATH=${em_root}/
ORCHESTRATOR_DB_STORAGE_PATH=${em_root}/persistence/orchestrator
ORCHESTRATOR_DB_PASSWORD=${orchestrator_db_pass}

WEATHER_SERVER_VERSION=latest
WEATHER_SERVER_HOST_PORT=${weather_server_port}
WEATHER_DB_STORAGE_PATH=${em_root}/persistence/weather
WEATHER_DB_PASSWORD=${weather_db_pass}
WEATHER_SEED_FILE=${em_root}/config/weather-data.sql

MARIADB_VERSION=latest"
echo "$template" > "$target"
}

function em_write_service_conf() {
  target="$1"
  host="$2"
  orchestrator_port="$3"
  weather_server_port="$4"
  # TODO : add SSL support
echo "{
  \"orchestrator\": \"http://${host}:${orchestrator_port}\",
  \"weatherserver\": \"http://${host}:${weather_server_port}\"
}" > "${target}"
}

function em_build_brokers() {
  echo "Building brokers ..."
  brokers_dir="$1"
  if [ ! -d "$brokers_dir" ];
    then
      git clone https://github.com/powertac/broker-images.git "${brokers_dir}"
      for broker_dir in "${brokers_dir}"/*/
      do
          broker_dir=${broker_dir%*/}
          broker_name="${broker_dir##*/}"
          if ! docker build --quiet --tag "powertac/${broker_name}" "${broker_dir}";
          then
            echo "ERROR: could not build broker '${broker_name}'"
          else
            echo "image build for '$broker_name' successful"
          fi
      done
    else
      echo "Skipping existing brokers dir ($brokers_dir)"
  fi
}