# Power TAC Experiment Manager (EM)


## Requirements
- Docker - [Installation instructions](https://docs.docker.com/engine/install/)
- Docker Compose - [Installation instructions](https://docs.docker.com/compose/install/)
- ~10GB+ of space on hard drive (and a lot more if you want to run a "production" instance)
- (root privileges - depending on your OS)


## Installation

First off, you should download or clone this repository on your system:

```shell
git clone https://github.com/fmilkau/powertac-experiment-manager
```

Now navigate to the project root directory:
```shell
cd /path/to/powertac-experiment-manager
```

### Configuration

On top of the configuration files included in this repository, you need a file containing your system-specific
configuration (e.g. passwords).  

Create a file with the name `.env` in your Experiment Manager directory and configure the EM using the following
template:

> _For a basic local deployment, you should edit the following env variables:_
>- `EM_ROOT_PATH`: **absolute** path to the EM data directory 
>- Passwords:
>  - `EM_ADMIN_PASSWORD` for access to the orchestrator (e.g. via web client)
>  - `EM_ORCHESTRATOR_DB_PASSWORD` to secure the orchestrator database
>  - `EM_WEATHER_DB_PASSWORD` to secure the weather server database

```dotenv
EM_HOST=127.0.0.1
EM_ROOT_PATH=/path/to/.powertac
EM_ADMIN_PASSWORD=<admin-password>

EM_WEB_CLIENT_VERSION=latest
EM_WEB_CLIENT_HOST_PORT=60600

EM_ORCHESTRATOR_VERSION=latest
EM_ORCHESTRATOR_HOST_PORT=60603
EM_ORCHESTRATOR_DB_PASSWORD=<orchestrator-db-password>

EM_WEATHER_SERVER_VERSION=latest
EM_WEATHER_SERVER_HOST_PORT=60606
EM_WEATHER_DB_PASSWORD=<weather-server-db-password>

EM_LOGPROCESSOR_VERSION=latest
EM_ANALYSIS_VERSION=latest
```

### Setup using CLI

The most straight-forward way to install the Experiment Manager is by using the included CLI `experiment-manager`. 

> If you have an existing Experiment Manager installation on your system, you can remove it using the `remove` and
> `purge` subcommands.
> 
> **_Please make sure you have the correct installation path configured when using the `purge` command._**

Use the `setup` subcommand to download and configure the required services:
```shell
experiment-manager setup
```

Once completed, you should see the following message as part of the output (your host address and port might differ):

```shell
+ Services created!
+ Please wait a bit to allow the services to setup their respective environments.
+ The web client should be available shortly (http://127.0.01:60600)."
```

> **Please be aware:** If the weather data is not available after a short while (e.g. when creating a new game), please restart the
> Experiment Manager using the `restart` subcommand.

### Manual Setup

On Linux, make sure that your current user has access to the `docker` command. Please refer to the documentation for
details: [Linux post-installation steps for Docker Engine](https://docs.docker.com/engine/install/linux-postinstall/).

### Pull service images

The Experiment Manager (EM) requires the following Docker images to work properly:

- `ghcr.io/powertac/orchestrator`
- `ghcr.io/powertac/web-client`
- `ghcr.io/powertac/weather-server`
- `ghcr.io/powertac/server`
- `ghcr.io/powertac/log-processor`
- `ghcr.io/powertac/analysis`

You can use the `docker pull` command to pull (download) the latest images:

```shell
docker pull ghcr.io/powertac/orchestrator:latest
docker pull ghcr.io/powertac/web-client:latest
docker pull ghcr.io/powertac/server:latest 
docker pull ghcr.io/powertac/weather-server:latest
docker pull ghcr.io/powertac/log-processor:latest
docker pull ghcr.io/powertac/analysis:latest
```

The images are currently hosted on GitHub ([Powertac > Packages](https://github.com/orgs/powertac/packages)) where you
can find a list of available image versions. The latest stable versions are always tagged as `latest`, e.g.
`ghcr.io/powertac/server:latest`.


### Run `docker compose`

The EM consists of several core services that are run inside Docker containers:

- Orchestrator ([powertac/powertac-experiment-scheduler](https://github.com/powertac/powertac-experiment-scheduler))
- Web Client ([powertac/web-client](https://github.com/powertac/web-client))
- Weather Server ([powertac/powertac-weather-server](https://github.com/powertac/powertac-weather-server))
- Databases for each the Orchestrator and Weather Server

These services are managed via [Docker Compose](https://docs.docker.com/compose/). Please refer to its documentation for
a complete reference of available operations.

All other services, such as the Power TAC Server, brokers, log processors and analysis tools, are managed by the
orchestrator. 

Switch to your EM directory and run the `docker compose` command:

```shell
cd /path/to/powertac-experiment-manager
docker compose up --detach
```

This will create and configure the required service containers. On first time setup, this command may take some time to
complete.


### Check your installation

Using the default configuration, the web client should now be available in your browser via http://localhost:60600
or in a more generalized form via `http://<EM_HOST>:<EM_WEB_CLIENT_HOST_PORT>`.


## Adding broker images

To run Power TAC simulations (games), the EM requires one or more broker images. Please refer to the
[powertac/broker-images](https://github.com/powertac/broker-images) repository for build instructions for some of the
existing brokers.

New brokers with can be added to the experiment manager via the user interface at any time.


## Running the Experiment Manager

### Using the CLI

You can use the following CLI subcommands to control the EM services:

```shell
experiment-manager start
experiment-manager stop
experiment-manager restart
experiment-manager status
```

### Using Docker Compose

Using the following commands in the EM's root directory will respectively start and stop the service containers: 

```shell
# stop
docker compose stop

# start
docker compose start
```

### Remove

This command will remove the service containers:

```shell
docker compose down
```

To completely remove all associated resources, you must also remove the EM files located in the path configured in the
`EM_ROOT_PATH` variable which defaults to `/path/to/powertac-experiment-manager/.powertac`

```shell
rm -rf /path/to/powertac-experiment-manager/.powertac
```

**Please be advised:** The last step removes all data related to the EM including game data and currently requires root
privileges. The latter will most likely change in a future update.

