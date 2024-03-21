#!/usr/bin/env bash

# This script contains functions to interact with SEDA contracts.

# Grab the directory where this script is located
SCRIPTS_DIR="$(dirname "$0")"
# Source common functions
bash "${SCRIPTS_DIR}/common.sh"

# Queries a contract and outputs the result
# Usage: smart_query TARGET_CONTRACT QUERY_MSG
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_smart_query() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC
    local OUTPUT="$($SEDA_BINARY query wasm contract-state smart $1 $2 --node $SEDA_CHAIN_RPC --output json)"
    echo $OUTPUT
}

# Executes an arbitrary message on a contract and outputs the transaction hash
# Usage: wasm_execute TARGET_CONTRACT EXECUTE_MSG FROM AMOUNT
# Requires: SEDA_BINARY, jq, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
seda_wasm_execute() {
		check_commands $SEDA_BINARY jq
		check_env_vars SEDA_CHAIN_RPC SEDA_CHAIN_ID
    local OUTPUT="$($SEDA_BINARY tx wasm execute $1 $2 --from $3 --node $SEDA_CHAIN_RPC ${TXN_GAS_FLAGS} -y --output json --chain-id $SEDA_CHAIN_ID --amount "$4"seda)"
    echo $OUTPUT
    local TXHASH=$(echo "$OUTPUT" | jq -r '.txhash')
    echo $TXHASH
}

# Stores a contract and outputs the code_id
# Usage: store_contract CONTRACT_NAME_PATH FROM
# Requires: SEDA_BINARY, jq, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
seda_store_contract() {
		check_commands $SEDA_BINARY jq
		check_env_vars SEDA_DEV_ACCOUNT SEDA_CHAIN_RPC SEDA_CHAIN_ID
    local output="$($SEDA_BINARY tx wasm store "$1" --node $SEDA_CHAIN_RPC --from $2 --chain-id $SEDA_CHAIN_ID ${TXN_GAS_FLAGS} --output json -y)"
    local TXHASH=$(echo $output | jq -r '.txhash')
    echo "Transaction Hash: $TXHASH"
    echo "Waiting to query to CODE_ID..."
    sleep ${SLEEP_TIME}
    output=$($SEDA_BINARY query tx $TXHASH --node $SEDA_CHAIN_RPC --output json)
    local CODE_ID=$(echo "$output" | jq -r '.events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value')
    echo "Deployed to CODE_ID=${CODE_ID}"
}

# Instantiates a contract and outputs the contract address
# Usage: instantiate_contract CODE_ID INSTANTIATE_MSG LABEL FROM ADMIN
# Requires: SEDA_BINARY, jq, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
seda_instantiate_contract() {
		check_commands $SEDA_BINARY jq
		check_env_vars SEDA_CHAIN_RPC SEDA_CHAIN_ID
    local output=$($SEDA_BINARY tx wasm instantiate $1 $2 --from $3 --admin $4 --node $SEDA_CHAIN_RPC --label "$3" ${TXN_GAS_FLAGS} -y --output json --chain-id $SEDA_CHAIN_ID)
    local TXHASH=$(echo "$output" | jq -r '.txhash')
    echo "Transaction Hash: $TXHASH"
    echo "Waiting to query for CONTRACT_ADDRESS..."
    sleep ${SLEEP_TIME}
    output="$($SEDA_BINARY query tx $TXHASH --node $SEDA_CHAIN_RPC --output json)"
    local CONTRACT_ADDRESS=$(echo "$output" | jq -r '.events[] | select(.type=="instantiate") | .attributes[] | select(.key=="_contract_address") | .value')
    echo "Deployed to CONTRACT_ADDRESS=${CONTRACT_ADDRESS}"
}

# Migrates a contract with a new implementation using a new code_id
# Usage: migrate_call OLD_CONTRACT_ADDRESS NEW_CODE_ID MIGRATION_MSG FROM
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
seda_migrate_call()  {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC SEDA_CHAIN_ID
    local OUTPUT="$($SEDA_BINARY tx wasm migrate $1 $2 $3 --node $SEDA_CHAIN_RPC --output json --from $4 --node $SEDA_CHAIN_RPC ${TXN_GAS_FLAGS} -y --output json --chain-id $SEDA_CHAIN_ID)"
    echo $OUTPUT
}

