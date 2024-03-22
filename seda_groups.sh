#!/usr/bin/env bash

# This script contains functions to interact with SEDA groups.

# Grab the directory where this script is located
SCRIPTS_DIR="$(dirname "$0")"
# Source common functions
bash "${SCRIPTS_DIR}/common.sh"

#  Queries all the groups that a user is an admin of
# Usage: seda_query_group_admin USER_ADDRESS
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_query_group_admin() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC
		local OUTPUT="$($SEDA_BINARY query group groups-by-admin $1 --node $SEDA_CHAIN_RPC --output json)"
		echo $OUTPUT
}

# Queries all members of a group
# Usage: seda_query_group_members GROUP_ID
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_query_group_members() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC
		local OUTPUT="$($SEDA_BINARY query group members $1 --node $SEDA_CHAIN_RPC --output json)"
		echo $OUTPUT
}

# Queries the info of a group
# Usage: seda_query_group_info GROUP_ID
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_query_group_info() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC
		local OUTPUT="$($SEDA_BINARY query group group-info $1 --node $SEDA_CHAIN_RPC --output json)"
		echo $OUTPUT
}

# Queries the info of a group policy
# Usage: seda_query_group_policy_info GROUP_ID
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_query_group_policy_info() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC
		local OUTPUT="$($SEDA_BINARY query group group-policy-info $1 --node $SEDA_CHAIN_RPC --output json)"
		echo $OUTPUT
}

# Creates a group proposal json file
# Usage: seda_create_group_proposal GROUP_POLICY_ADDR FROM_GROUP_MEM FILE_NAME MSG1 MSG2 ...
# Requires: jq
seda_create_group_proposal() {
    check_commands jq
    local group_policy_address="$1"
    local from_group_mem="$2"
    local file_name="$3"
    
    # Start constructing the JSON
    local json_part_begin="{
        \"group_policy_address\": \"$group_policy_address\",
        \"messages\": ["
    
    local json_part_end="],
        \"metadata\": \"ipfs://QmearrgtJxKHu37HnNjU1AQMnvWoXqwh6cWR8mytBJoFVv\",
        \"proposers\": [\"$from_group_mem\"]
    }"
    
    # Loop to construct messages part
    local messages=""
    local first=true
    for arg in "${@:4}"; do
        if [ "$first" = true ]; then
            messages="$arg"
            first=false
        else
            messages="$messages, $arg"
        fi
    done

    # Combine all parts
    local json="$json_part_begin$messages$json_part_end"

    # Use jq to format the string as proper JSON and save to file
    echo $json | jq . > "$file_name.json"
}

# Queries all proposals of a group by group policy
# Usage: seda_query_group_proposals GROUP_POLICY_ADDR
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_query_group_proposals() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC
		local OUTPUT="$($SEDA_BINARY query group proposals-by-group-policy $1 --node $SEDA_CHAIN_RPC --output json)"
		echo $OUTPUT
}

# Queries the latest proposal id of a group
# Usage: seda_query_group_latest_proposal_id GROUP_POLICY_ADDR
# Requires: SEDA_BINARY, jq, SEDA_CHAIN_RPC
seda_query_group_latest_proposal_id() {
		check_commands jq
		local OUTPUT=$(seda_query_group_proposals $1)
		echo "$(echo $OUTPUT | jq '.proposals[-1].id')"
}

# Submits a group proposal returns the transaction hash
# Usage: seda_submit_proposal FILE_NAME FROM
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
seda_submit_proposal() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC, SEDA_CHAIN_ID
		local output="$($SEDA_BINARY tx group submit-proposal $1 --from $2 --node $SEDA_CHAIN_RPC --chain-id  $SEDA_CHAIN_ID ${TXN_GAS_FLAGS})"
		echo $output
}

# Votes on a group proposal returns the transaction hash
# Usage: seda_proposal_vote PROPOSAL_ID FROM VOTE_OPTION VOTE_MESSAGE
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC
seda_proposal_vote() {
		check_commands $SEDA_BINARY
		local output="$($SEDA_BINARY group vote $1 $2 $3 "$4" --node $SEDA_CHAIN_RPC --chain-id  $SEDA_CHAIN_ID ${TXN_GAS_FLAGS})"
		echo $output
}

# Executes a group proposal returns the transaction hash
# Usage: seda_proposal_exec PROPOSAL_ID
# Requires: SEDA_BINARY, SEDA_CHAIN_RPC, SEDA_CHAIN_ID
seda_proposal_exec() {
		check_commands $SEDA_BINARY
		check_env_vars SEDA_CHAIN_RPC, SEDA_CHAIN_ID
		local output="$($SEDA_BINARY tx group exec $1 --from $DEV_ACCOUNT --node $SEDA_CHAIN_RPC --chain-id  $SEDA_CHAIN_ID ${TXN_GAS_FLAGS})"
		echo $output
}