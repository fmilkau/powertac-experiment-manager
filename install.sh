#!/usr/bin/env bash

# conventions
compose_file="experiment-manager.compose.yml"
service_conf="services.json"
env_file="experiment-manager.env"
service_name="pem"
web_client_default_port="60600"
orchestrator_default_port="60603"
weather_server_default_port="60606"


# load paths & resources
path_em=$(dirname "$(realpath "$0")")
path_bin="${path_em}/bin"
path_config="${path_em}/config"

source "${path_bin}/util.sh"

compose_command="$(em_compose_command)"
if [ $? -ne 0 ]; then
  echo "ERROR: docker compose command not available"
  exit 1
fi


# read config vars
read -re -p "Experiment Manager root directory:" -i "${PWD}/experiment-manager" root_dir
read -res -p "Database password:" db_pass
echo -ne "\n"
read -re -p "Web client port (press ENTER for default):" -i "$web_client_default_port" web_client_port
read -re -p "Orchestrator port (press ENTER for default):" -i "$orchestrator_default_port" orchestrator_port
read -re -p "Weather server port (press ENTER for default):" -i "$weather_server_default_port" weather_server_port
read -re -p "Build brokers ([y]es/[n]o):" should_build_brokers


# create dirs
if [ ! -d "$root_dir" ]; then
  mkdir -p "${root_dir}"
fi
em_config_dir="${root_dir}/config"
if [ ! -d "$em_config_dir" ]; then
  mkdir -p "${em_config_dir}"
fi
em_bin_dir="${root_dir}/bin"
if [ ! -d "$em_bin_dir" ]; then
  mkdir -p "${em_bin_dir}"
fi


# write configs
em_write_env "${em_config_dir}/${env_file}" \
  "$root_dir" \
  "$web_client_port" \
  "$orchestrator_port" \
  "$weather_server_port" \
  "$db_pass" \
  "$db_pass" \
  "$(em_host_ip)"
em_write_service_conf "${em_config_dir}/${service_conf}" \
  "$(em_host)" \
  "$orchestrator_port" \
  "$weather_server_port"


# copy resources
cp "$path_bin"/* "${em_bin_dir}"
cp "$path_config"/* "${em_config_dir}"


# TODO : load server(s)


# (optional) building brokers
if [ "$should_build_brokers" == "y" ] || [ "$should_build_brokers" == "yes" ]; then
  em_build_brokers "${root_dir}/brokers"
  # TODO : add file to automatically add brokers to orchestrator on first time startup
fi

# create containers
$compose_command \
  --project-directory "${em_config_dir}" \
  --file "${em_config_dir}/${compose_file}" \
  --env-file "${em_config_dir}/${env_file}" \
  --project-name "${service_name}" \
  up --no-start

echo -e "\nYou can now start the experiment manager by using the start script:\n${em_bin_dir}/start.sh\n"