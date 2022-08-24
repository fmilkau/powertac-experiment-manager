#!/usr/bin/env bash
# check requirements
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not available.' >&2
  exit 1
fi
compose_command="docker-compose"
if ! [ -x "$(command -v docker-compose)" ]; then
  compose_command="docker compose"
fi
if ! $compose_command > /dev/null 2>&1; then
  echo "ERROR: compose command '$compose_command' not available" >&2
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
echo "HOST_IP=${host_ip}
UI_VERSION=dev
UI_HOST_PORT=8060
ORCHESTRATOR_VERSION=dev
ORCHESTRATOR_HOST_PORT=8050
ORCHESTRATOR_ROOT_PATH=${root_dir}/
ORCHESTRATOR_DB_STORAGE_PATH=${root_dir}/persistence/orchestrator
ORCHESTRATOR_DB_PASSWORD=stooge72lyons62Abstract
WEATHER_SERVER_VERSION=alpha22
WEATHER_SERVER_HOST_PORT=8070
WEATHER_DB_STORAGE_PATH=${root_dir}/persistence/weather
WEATHER_SEED_FILE=${deployment_dir}/weather-data.sql
WEATHER_DB_PASSWORD=repulses52besmirch39galena
MARIADB_VERSION=latest" > "${deployment_dir}/experiment-manager.env"
echo "{
  \"orchestrator\": \"http://${host_ip}:8050\",
  \"weather\": \"http://${host_ip}:8070\"
}" > "${deployment_dir}/discovery.json"
echo -e "#!/usr/bin/env bash
${compose_command} -f ${deployment_dir}/experiment-manager.yml --env-file ${deployment_dir}/experiment-manager.env -p pem up -d
echo -e \"http://${host_ip}:8060\"" > "${deployment_dir}/em-start.sh"
chmod +x "${deployment_dir}/em-start.sh"

# copy resources
script_path=$(realpath "$BASH_SOURCE")
installer_dir=$(dirname "$script_path")
cp "$installer_dir"/config/* "${deployment_dir}"

# build brokers
brokers_dir="${root_dir}/brokers"
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

# create containers
$compose_command \
  --project-directory "${deployment_dir}" \
  --file "${deployment_dir}/experiment-manager.yml" \
  --env-file "${deployment_dir}/experiment-manager.env" \
  --project-name pem \
  up --no-start

echo -e "\nYou can now start the experiment manager by using the start script:\n${deployment_dir}/em-start.sh\n"