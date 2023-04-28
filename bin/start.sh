#!/usr/bin/env bash

path_bin=$(dirname "$(realpath "$0")")
path_em=$(dirname "$path_bin")
path_config="${path_em}/config"

source "${path_bin}/util.sh"

compose_command="$(em_compose_command)"

echo "Starting containers ..."
$compose_command \
  --project-directory "${path_config}" \
  --file "${path_config}/experiment-manager.compose.yml" \
  --env-file "${path_config}/experiment-manager.env" \
  --project-name "pem" \
  start