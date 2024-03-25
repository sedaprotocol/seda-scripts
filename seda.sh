#!/usr/bin/env bash

# This script contains functions to interact with SEDA.

# Grab the directory where this script is located
SCRIPTS_DIR="$(dirname "$0")"
# Source common functions
bash "${SCRIPTS_DIR}/common.sh"

# Transfers SEDA tokens
# Usage: transfer_seda FROM RECEIVER AMOUNT(in seda)
# Requires: SEDA_BINARY, jq, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
transfer_seda() {
	usage "${FUNCNAME[0]}" 3 "$#" "FROM" "RECEIVER" "AMOUNT(in seda)"
	check_commands $SEDA_BINARY jq
	check_env_vars SEDA_DEV_ACCOUNT SEDA_CW_TARGET_CONTRACT SEDA_CHAIN_RPC SEDA_CHAIN_ID
	local output="$($SEDA_BINARY tx bank send $1 $2 ${3}seda --node $SEDA_CHAIN_RPC --chain-id $SEDA_CHAIN_ID ${TXN_GAS_FLAGS} --output json -y)"
	local txhash=$(echo $output | jq -r '.txhash')
	echo "Transaction Hash: $txhash"
}
