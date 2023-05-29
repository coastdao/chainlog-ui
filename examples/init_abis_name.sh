#!/bin/bash
network=$2
if [ -z "$network" ]; then
  network="testchain"
fi
PROJECT_DIR=${SUBGRAPH_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]%/*}")/.." && pwd)}
json=$(cat "$PROJECT_DIR"/api/testnet/active.json)
keys=$(echo "$json" | jq -r 'keys[]')
DSS_DEPLOY_PROJECT_DIR=/Users/pundix045/go/src/solidity/maker/contract/dss-deploy-scripts

help="Usage: script.sh [<options>] <command> [<args>]
   or: script.sh <command> --help

Description of the script.

Options:
    -h, --help        Show help message and exit.

Commands:
    init_abis <chainName>            Create api/<network>/active.json file name.json to abis
                                     Initialize abi to abis file from dss-deploy-scripts.

Examples:
    script.sh init_abis testnet

If no chainName is provided, the default is testnet.
"

function get_lib_name() {
  contract_class=$1
  lib_name=$(jq -r '.[] |select(.contracts[].name=="'"$contract_class"'").lib' "$DSS_DEPLOY_PROJECT_DIR/contracts.json")
  echo "$lib_name"
}

function get_class_name() {
  contract_name=$1
  contract_class=$(jq -r '.[] as $c|$c.contracts[]|select(.name=="'"$contract_name"'")|.class' "$DSS_DEPLOY_PROJECT_DIR/contracts.json")
  echo "$contract_class"
}

function init_abis() {
  mkdir -p "$PROJECT_DIR"/abis/testnet
  for key in $keys; do
    if [ "$key" == "DEPLOYER" ]; then
      continue
    fi
    lib_name="$(get_lib_name "$key")"
    class_name="$(get_class_name "$key")"
    path_abi="$DSS_DEPLOY_PROJECT_DIR/out/$network/abi/$lib_name/$class_name.abi"

    new_abi_file_name="$PROJECT_DIR"/abis/testnet/"$key".json
    if [ -s "$new_abi_file_name" ]; then
      echo "Skipping file: $new_abi_file_name (already contains content)"
    else
      echo "Copying value to file: $new_abi_file_name"
      cat "$path_abi" >"$new_abi_file_name"
    fi

    if [ -s "$new_abi_file_name" ]; then
      echo "$new_abi_file_name" >>"$PROJECT_DIR"/abis/AllReadyAbiList.txt
    else
      echo "$new_abi_file_name" >>"$PROJECT_DIR"/abis/NoAbiList.txt
    fi

  done
}

if [ "$1" == "init_abis" ] || [ "$1" == "init_abis_name" ]; then
  "$@" || (echo "failed: $0" "$@" && exit 1)
else
  echo "$help"
fi



