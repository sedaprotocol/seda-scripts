#!/usr/bin/env bash

# This script contains functions to help with creating proposal group messages.

# Grab the directory where this script is located
SCRIPTS_DIR="$(dirname "$0")"
# Source common functions
source "${SCRIPTS_DIR}/../common.sh"
# Source group functions
source "${SCRIPTS_DIR}/../libs/seda_groups.sh"

# Creates a group proposal json file for storing a contract
# Usage: seda_store_proposal CONTRACT_ADDR_TO_MIGRATE CODE_ID_NEW_CONTRACT GROUP_POLICY_ADDR FROM_GROUP_MEM MIGRATE_MSG_JSON FILE_NAME
# Requires: jq

usage "$0" 6 "$#" "CONTRACT_ADDR_TO_MIGRATE" "CODE_ID_NEW_CONTRACT" "GROUP_POLICY_ADDR" "FROM_GROUP_MEM" "MIGRATE_MSG_JSON" "FILE_NAME"

CONTRACT_ADDR_TO_MIGRATE=$1
CODE_ID_NEW_CONTRACT=$2
GROUP_POLICY_ADDR=$3
FROM_GROUP_MEM=$4
MIGRATE_MSG_JSON=$5
FILE_NAME=$6

migrate_msg=$(cat "$MIGRATE_MSG_JSON")
msg_migrate_contract="{\"@type\":\"/cosmwasm.wasm.v1.MsgMigrateContract\",\"sender\":\"$GROUP_POLICY_ADDR\",\"contract\":\"$CONTRACT_ADDR_TO_MIGRATE\",\"code_id\":\"$CODE_ID_NEW_CONTRACT\",\"msg\":$migrate_msg}"
seda_create_group_proposal "$GROUP_POLICY_ADDR" "$FROM_GROUP_MEM" "$FILE_NAME" "$msg_migrate_contract"
