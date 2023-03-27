# Power TAC Experiment Manager Installer

## Requirements
- Docker (https://docs.docker.com/engine/install/)
- Docker Compose (https://docs.docker.com/compose/install/)
- ~10GB+ of space on hard drive (and a lot more if you want to run a "production" instance)
- root access 

## Usage
The installation command must be executed by a user with Docker privileges. Use the following command to add a user to
the `docker` group: 

```shell
usermod -aG docker <USER_NAME>
```

Afterwards you can start the installer by calling the installation script:

```shell
./em-install.sh
```