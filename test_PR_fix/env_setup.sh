#!/bin/bash

#////////////////////////////////////////////////////////////////
#   
#   Make sure to run this script with the `source` command,
#   as I suggested int the pull request write up, otherwise 
#   it won't be able to set the CONTRACTS_NODE environment 
#   variables; you will basically run it like this:
#   source env_setup.sh
#   
#   SIDE NOTE:
#   ========== 
#   This script is meant to be run on debian-based systems,
#   and the environment variables it sets are only valid for
#   the shell session in which it is run on; this is meant
#   to be a temporary quick setup to test the PR I made.
#
#////////////////////////////////////////////////////////////////


# Some ANSI colors I'm using to improve the UX by making
# this bash script output more readable.
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m' 
RESET='\033[0m'
SEPARATOR="========================================================"

# Some basic UX to print messages with padding, color, and prefix
print_message() {
    color=$1
    message=$2
    prefix=">>> "
    echo -e "${color}${prefix}${message}${RESET}\n"
}

echo # A quick fix to add top padding to the output

# This constructs the path to the substrate-contracts-node binary
CONTRACTS_NODE="$(pwd)/substrate-contracts-node"

# This checks if the binary exists and sets the path:
#
# - if it does exist, it sets CONTRACTS_NODE environment variable 
#   that will be used by ink_e2e crate to run the local node 
#   and perform the E2E tests.
#
# - if it doesn't exist, it basically tells you what to do.
#
if [ -d "$CONTRACTS_NODE" ] || [ -f "$CONTRACTS_NODE" ]; then
    export CONTRACTS_NODE
    print_message $GREEN "Path to substrate-contract-node successfully set"
else
    print_message $RED "Failed to set path to substrate-contract-node"
    cat <<EOM
    Make sure you have substrate-contracts-node binary 
    in the same directory as this bash script and then
    run this script again to complete this step!
    
EOM
    return 1
fi

# This finds the node_proc.rs file for the latest version of ink_e2e
NODE_PROC_PATH=$(find ~/.cargo -type f -name "node_proc.rs" | sort -V | tail -n 1)
if [ -n "$NODE_PROC_PATH" ]; then
    echo -e "    Here is the path to the file where you will paste my fix:\n"
    echo -e "    $NODE_PROC_PATH\n"
    print_message $BLUE $SEPARATOR
else
    print_message $RED "node_proc.rs file not found:"
    cat <<EOM
    Make sure you have ink_e2e crate installed and
    then run this bash script again to complete this
    step successfully!
    
EOM
    return 1
fi

# This gets the path to the local ink_e2e directory
INK_E2E_PATH=$(dirname $(dirname $NODE_PROC_PATH))

if [ -n "$INK_E2E_PATH" ]; then
    echo -e "    Change ink_e2e dependency to point to your local ink_e2e,"
    echo -e "    yours looks like this:\n"
    echo -e "    ink_e2e = { path = \"$INK_E2E_PATH\" }\n"
else
    print_message $RED "Failed to find ink_e2e directory"
    return 1
fi

print_message $GREEN "Script completed successfully!"
echo -e "    Now proceed with the rest of steps I suggested on the PR\n"
return 0
