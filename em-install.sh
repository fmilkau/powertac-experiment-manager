#!/usr/bin/env bash

compose_file="experiment-manager.compose.yml"
env_file="experiment-manager.env"
start_script="em-start.sh"
service_name="pem"

# check requirements
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

# directories
read -re -p "Experiment Manager root directory:" -i "${PWD}/experiment-manager" root_dir
if [ ! -d "$root_dir" ]; then
  mkdir -p "${root_dir}"
fi
deployment_dir="${root_dir}/deploy"
if [ ! -d "$deployment_dir" ]; then
  mkdir -p "${deployment_dir}"
fi

# host ip address
read -re -p "Host IP address:" host_ip
# TODO: add input for passwords and ports

# create config files
# experiment-manager.env
echo "HOST_IP=${host_ip}
WEB_CLIENT_VERSION=latest
WEB_CLIENT_HOST_PORT=8060

ORCHESTRATOR_VERSION=latest
ORCHESTRATOR_HOST_PORT=8050
ORCHESTRATOR_ROOT_PATH=${root_dir}/
ORCHESTRATOR_DB_STORAGE_PATH=${root_dir}/persistence/orchestrator
ORCHESTRATOR_DB_PASSWORD=stooge72lyons62Abstract

WEATHER_SERVER_VERSION=latest
WEATHER_SERVER_HOST_PORT=8070
WEATHER_DB_STORAGE_PATH=${root_dir}/persistence/weather
WEATHER_SEED_FILE=${deployment_dir}/weather-data.sql
WEATHER_DB_PASSWORD=repulses52besmirch39galena

MARIADB_VERSION=latest" > "${deployment_dir}/${env_file}"

# services.json (web-client)
echo "{
  \"orchestrator\": \"http://${host_ip}:8050\",
  \"weatherserver\": \"http://${host_ip}:8070\"
}" > "${deployment_dir}/services.json"

# start-script
# TODO : expand control script (stop, remove, etc.)
echo -e "#!/usr/bin/env bash
${compose_command} -f ${deployment_dir}/${compose_file} --env-file ${deployment_dir}/experiment-manager.env -p ${service_name} up -d
echo -e \"You can now open the EM UI by using this url: http://${host_ip}:8060. The orchestrator might take a bit to start however.\"" > "${deployment_dir}/${start_script}"
chmod +x "${deployment_dir}/${start_script}"

# copy resources
script_path=$(realpath "$BASH_SOURCE")
installer_dir=$(dirname "$script_path")
cp "$installer_dir"/config/* "${deployment_dir}"

# build brokers
# TODO : make this optional
# TODO : add file to automatically add brokers to orchestrator on first time startup
brokers_dir="${root_dir}/brokers"
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

# create containers
$compose_command \
  --project-directory "${deployment_dir}" \
  --file "${deployment_dir}/${compose_file}" \
  --env-file "${deployment_dir}/${env_file}" \
  --project-name "${service_name}" \
  up --no-start

# TODO : point towards control script
echo -e "\nYou can now start the experiment manager by using the start script:\n${deployment_dir}/${start_script}\n"