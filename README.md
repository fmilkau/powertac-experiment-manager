# Power TAC Experiment Manager


## Requirements
- Docker (https://docs.docker.com/engine/install/)
- Docker Compose (https://docs.docker.com/compose/install/)
- ~10GB+ of space on hard drive (and a lot more if you want to run a "production" instance)
- root privileges


## Preparation

### Power TAC server image(s)

Use the `docker pull` command to download the server image(s):

```shell
docker pull ghcr.io/powertac/server:<VERSION>
```

A list of available image versions can be found here:
[Power TAC packages > server](https://github.com/powertac/powertac-server/pkgs/container/server). The most recent stable
server image will have the `latest` tag: `ghcr.io/powertac/server:latest`.

### Broker images

Please refer to the [powertac/broker-images](https://github.com/powertac/broker-images) repository for installation
instructions.

### Configuration

Rename the default configuration `.env.example` to `.env` and adapt it to your requirements. The default configuration
is designed to run the Experiment Manager in local mode, meaning that it is only available on the machine it is running
on. For local deployment, simply change the database passwords 
(`EM_ORCHESTRATOR_DB_PASSWORD`, `EM_WEATHER_DB_PASSWORD`) and you're good to go.

```dotenv
EM_HOST=127.0.0.1

EM_WEB_CLIENT_VERSION=latest
EM_WEB_CLIENT_HOST_PORT=60600

EM_ORCHESTRATOR_VERSION=latest
EM_ORCHESTRATOR_HOST_PORT=60603
EM_ORCHESTRATOR_DB_PASSWORD=<password>

EM_WEATHER_SERVER_VERSION=latest
EM_WEATHER_SERVER_HOST_PORT=60606
EM_WEATHER_DB_PASSWORD=<password>
```


## Running the Experiment Manager

The Experiment Manager consists of five core services that are run inside Docker containers:

- Orchestrator ([powertac/powertac-experiment-scheduler](https://github.com/powertac/powertac-experiment-scheduler))
- Web Client ([powertac/web-client](https://github.com/powertac/web-client))
- Weather Server ([powertac/powertac-weather-server](https://github.com/powertac/powertac-weather-server))
- Databases for each the Orchestrator and Weather Server 

These services are managed via [Docker Compose](https://docs.docker.com/compose/). Please refer to its documentation for
a complete reference of available operations.

Switch to your Experiment Manager directory for the following commands to work:

```shell
cd /path/to/experiment-manager
```

### Setup

```shell
docker compose --file em.compose.yml --env-file .env up --detach
```

On first time setup, this command may take some time to complete. Afterwards the web client should be available in your
browser via `http://localhost:60600` (assuming you used the default configuration) or in a more generalized form via
`http://<EM_HOST>:<EM_WEB_CLIENT_HOST_PORT>`.

### Stop & Start

```shell
# stop
docker compose --file em.compose.yml --env-file .env stop

# start
docker compose --file em.compose.yml --env-file .env start
```

These commands will respectively start and stop the service containers.

### Remove

```shell
docker compose --file em.compose.yml --env-file .env down
```

This command will remove the service containers. To completely remove all associated resources
(e.g. for a re-installation), remove the following directories as well: `baselines`, `brokers`, `games`, `persistence`
and `treatments`:

```shell
rm -rf brokers/ games/ baselines/ persistence/ treatments/
```