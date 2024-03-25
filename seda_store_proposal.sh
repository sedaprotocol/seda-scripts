#!/usr/bin/env bash

# This script contains functions to help with creating proposal group messages.

# Grab the directory where this script is located
SCRIPTS_DIR="$(dirname "$0")"
# Source common functions
source "${SCRIPTS_DIR}/common.sh"
# Source group functions
source "${SCRIPTS_DIR}/seda_groups.sh"

# Creates a group proposal json file for storing a contract
# Usage: seda_store_proposal CONTRACT_PATH GROUP_POLICY_ADDR FROM_GROUP_MEM FILE_NAME
# Requires: jq, base64
usage "$0" 4 "$#" "CONTRACT_PATH" "GROUP_POLICY_ADDR" "FROM_GROUP_MEM" "FILE_NAME"
check_commands base64

CONTRACT_PATH=$1
GROUP_POLICY_ADDR=$2
FROM_GROUP_MEM=$3
FILE_NAME=$4

wasm_bytecode=$(base64 -w 0 "$CONTRACT_PATH")
msg_store_code="{\"@type\":\"/cosmwasm.wasm.v1.MsgStoreCode\",\"sender\":\"$GROUP_POLICY_ADDR\",\"wasm_byte_code\":\"$wasm_bytecode\"}"
seda_create_group_proposal "$GROUP_POLICY_ADDR" "$FROM_GROUP_MEM" "$FILE_NAME" "$msg_store_code"
