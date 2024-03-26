#!/usr/bin/env bash

# This script contains functions to help with creating proposal group messages.

# Grab the directory where this script is located
SCRIPTS_DIR="$(dirname "$0")"
# Source common functions
source "${SCRIPTS_DIR}/../common.sh"
# Source group functions
source "${SCRIPTS_DIR}/../libs/seda_groups.sh"

# Creates a group proposal json file for instantiating a contract
# Usage: seda_store_proposal CODE_ID GROUP_POLICY_ADDR FROM_GROUP_MEM FILE_NAME INSTANTIATE_MSG_JSON
# Requires: jq

usage "$0" 5 "$#" "CODE_ID" "GROUP_POLICY_ADDR" "FROM_GROUP_MEM" "FILE_NAME" "INSTANTIATE_MSG_JSON"

CODE_ID=$1
GROUP_POLICY_ADDR=$2
FROM_GROUP_MEM=$3
FILE_NAME=$4
INSTANTIATE_MSG_JSON=$5

msg_instantiate_contract="{\"@type\":\"/cosmwasm.wasm.v1.MsgInstantiateContract\",\"sender\":\"$GROUP_POLICY_ADDR\",\"code_id\":\"$CODE_ID\",\"label\":\"$CODE_ID\",\"msg\":$INSTANTIATE_MSG_JSON,\"funds\":[],\"admin\":\"$GROUP_POLICY_ADDR\"}"
seda_create_group_proposal "$GROUP_POLICY_ADDR" "$FROM_GROUP_MEM" "$FILE_NAME" "$msg_instantiate_contract"
