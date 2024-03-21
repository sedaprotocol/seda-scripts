#!/usr/bin/env bash

# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status.
set -uo pipefail
trap 's=$?; error "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# =============================================================================
#                               GLOBAL VARIABLES
# =============================================================================

# If not defined, set to default values
SEDA_BINARY=${SEDA_BINARY:-"sedad"}
TXN_GAS_FLAGS=${TXN_GAS_FLAGS:-"--gas-prices 0.1aseda --gas auto --gas-adjustment 1.6"}
SLEEP_TIME=${SLEEP_TIME:-10}

# =============================================================================
#                               COMMON FUNCTIONS
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
            error "Command \`${command_name}\` not found."
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
