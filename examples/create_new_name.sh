#!/bin/bash
network=$2
if [ -z "$network" ]; then
  network="dhobyghaut"
fi
PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]%/*}")/.." && pwd)}
json=$(cat "$PROJECT_DIR"/api/"$network"/active.json)
keys=$(echo "$json" | jq -r 'keys[]')

help="Usage: create_new_name.sh [<options>] <command> [<args>]
   or: create_new_name.sh <command> --help

Description of the script.

Options:
    -h, --help        Show help message and exit.

Commands:
    create_abis <chainName>            Create api/<chainName>/active.json file name.json to abis

Examples:
    ./create_new_name.sh create_abis testnet

If no chainName is provided, the default is testnet.
"


function create_abis() {
  for key in $keys; do
    echo "key: $key"
    if [ "$key" == "DEPLOYER" ]; then
      continue
    fi
    new_file_name="$PROJECT_DIR"/abis/$network/"$key".json
    touch "$new_file_name"
  done
}

if [ "$1" == "create_abis" ]; then
  "$@" || (echo "failed: $0" "$@" && exit 1)
else
  echo "$help"
fi


