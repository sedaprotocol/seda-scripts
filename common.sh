#!/usr/bin/env bash

# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status.
set -uo pipefail
trap 's=$?; error "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# =============================================================================
#                               GLOBAL VARIABLES
# =============================================================================

# Seda chain binary
SEDA_BINARY="sedad"

# If not defined, set to default values
TXN_GAS_FLAGS=${TXN_GAS_FLAGS:-"--gas-prices 0.1aseda --gas auto --gas-adjustment 1.6"}
SLEEP_TIME=${SLEEP_TIME:-10}

# =============================================================================
#                               HELPER FUNCTIONS
# =============================================================================

# Prints an error message to stderr
# Usage: error "Error message"
error() { printf "\033[31mERROR: \033[0m%s\n" "$1" >&2; }

# Checks if command(s) exists on the sytem
# Usage: check_commands COMMAND_NAME1 COMMAND_NAME2 ...
check_commands() {
    local command_names=("$@")
		local command_unset=false
    for command_name in "${command_names[@]}"; do
        if ! command -v ${command_name} > /dev/null 2>&1; then
            error ""Command \`${command_name}\` not found.""
            command_unset=true
        fi
    done
    [  "$command_unset" = "true"  ] && exit 1

    return 0
}

# Checks if env vars are set
# Usage: check_env_vars VAR_NAME1 VAR_NAME2 ...
check_env_vars() {
    local var_names=("$@")
		local var_unset=false
    for var_name in "${var_names[@]}"; do
        [ -z "${!var_name+x}" ] && error "$var_name must be defined" && var_unset=true
    done
    [ "$var_unset" = "true" ] && exit 1

    return 0
}

# Pushes shell variables to a .env file
# Usage: update_env_file VAR_NAME VALUE
update_env_file() {
    local variable_name="$1"
    local value="$2"

    echo "# $(date)" >> ../.env
    echo "$variable_name=$value" >> ../.env
}

# =============================================================================
#                               CALLABLE FUNCTIONS
# =============================================================================

# Stores a contract and outputs the code_id
# Usage: store_contract CONTRACT_NAME_PATH
# Requires: SEDA_DEV_ACCOUNT, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
store_contract() {
		check_env_vars SEDA_DEV_ACCOUNT SEDA_CHAIN_RPC SEDA_CHAIN_ID
    local output="$($SEDA_BINARY tx wasm store "$1" --node $SEDA_CHAIN_RPC --from $SEDA_DEV_ACCOUNT --chain-id $SEDA_CHAIN_ID ${TXN_GAS_FLAGS} --output json -y)"
    local TXHASH=$(echo $output | jq -r '.txhash')
    echo "Transaction Hash: $TXHASH"
    echo "Waiting to query to CODE_ID..."
    sleep ${SLEEP_TIME}
    output=$($SEDA_BINARY query tx $TXHASH --node $SEDA_CHAIN_RPC --output json)
    local CODE_ID=$(echo "$output" | jq -r '.events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value')
    echo "Deployed to CODE_ID=${CODE_ID}"
}

# Instantiates a contract and outputs the contract address
# Usage: instantiate_contract CODE_ID INSTANTIATE_MSG LABEL
# Requires: SEDA_DEV_ACCOUNT, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
instantiate_contract() {
		check_env_vars SEDA_DEV_ACCOUNT SEDA_CHAIN_RPC SEDA_CHAIN_ID
    output=$($SEDA_BINARY tx wasm instantiate $1 $2 --from $SEDA_DEV_ACCOUNT --admin $SEDA_DEV_ACCOUNT  --node $SEDA_CHAIN_RPC --label "$3" ${TXN_GAS_FLAGS} -y --output json --chain-id $SEDA_CHAIN_ID)
    TXHASH=$(echo "$output" | jq -r '.txhash')
    echo "Transaction Hash: $TXHASH"
    echo "Waiting to query for CONTRACT_ADDRESS..."
    sleep ${SLEEP_TIME}
    output="$($SEDA_BINARY query tx $TXHASH --node $SEDA_CHAIN_RPC --output json)"
    CONTRACT_ADDRESS=$(echo "$output" | jq -r '.events[] | select(.type=="instantiate") | .attributes[] | select(.key=="_contract_address") | .value')
    echo "Deployed to CONTRACT_ADDRESS=${CONTRACT_ADDRESS}"
}

# Queries a contract and outputs the result
# Usage: smart_query TARGET_CONTRACT QUERY_MSG
# Requires: SEDA_CHAIN_RPC
smart_query() {
		check_env_vars SEDA_CHAIN_RPC
    OUTPUT="$($SEDA_BINARY query wasm contract-state smart $1 $2 --node $SEDA_CHAIN_RPC --output json)"
    echo $OUTPUT
}

# Executes an arbitrary message on a contract and outputs the transaction hash
# Usage: wasm_execute TARGET_CONTRACT EXECUTE_MSG AMOUNT
# Requires: SEDA_DEV_ACCOUNT, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
wasm_execute() {
		check_env_vars SEDA_DEV_ACCOUNT SEDA_CHAIN_RPC SEDA_CHAIN_ID
    OUTPUT="$($SEDA_BINARY tx wasm execute $1 $2 --from $SEDA_DEV_ACCOUNT --node $SEDA_CHAIN_RPC ${TXN_GAS_FLAGS} -y --output json --chain-id $SEDA_CHAIN_ID --amount "$3"seda)"
    echo $OUTPUT
    TXHASH=$(echo "$OUTPUT" | jq -r '.txhash')
    echo $TXHASH
}

# Migrates a contract with a new implementation using a new code_id
# Usage: migrate_call OLD_CONTRACT_ADDRESS NEW_CODE_ID MIGRATION_MSG
# Requires: SEDA_DEV_ACCOUNT, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
migrate_call()  {
		check_env_vars SEDA_DEV_ACCOUNT SEDA_CHAIN_RPC SEDA_CHAIN_ID
    OUTPUT="$($SEDA_BINARY tx wasm migrate $1 $2 $3 --node $SEDA_CHAIN_RPC --output json --from $SEDA_DEV_ACCOUNT --node $SEDA_CHAIN_RPC ${TXN_GAS_FLAGS} -y --output json --chain-id $SEDA_CHAIN_ID)"
    echo $OUTPUT
}

# Transfers SEDA tokens
# Usage: transfer_seda RECEIVER AMOUNT
# Requires: SEDA_DEV_ACCOUNT, SEDA_CW_TARGET_CONTRACT, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
transfer_seda(){
		check_env_vars SEDA_DEV_ACCOUNT SEDA_CW_TARGET_CONTRACT SEDA_CHAIN_RPC SEDA_CHAIN_ID
    output="$($SEDA_BINARY tx bank send $SEDA_DEV_ACCOUNT $1 ${2}seda --node $SEDA_CHAIN_RPC --chain-id $SEDA_CHAIN_ID ${TXN_GAS_FLAGS} --output json -y)"
    txhash=$(echo $output | jq -r '.txhash')
    echo "Transaction Hash: $txhash"
}
