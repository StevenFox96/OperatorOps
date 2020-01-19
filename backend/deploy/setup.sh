#!/bin/bash

# Just a handy reference to "this dir"
#
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Keep a reference of sub-shell errors for better error-handling
#
LAST_RESULT=""



# This are the env vars we need (defaults for test info on Kylin)
#
NATIVE_EOS_SYMBOL=${NATIVE_EOS_SYMBOL:-"EOS"}

OPERATOR_ACCOUNT_NAME=${OPERATOR_ACCOUNT_NAME}
OPERATOR_PRIVATE_KEY=${OPERATOR_PRIVATE_KEY}
OPERATOR_CHAIN_ID=${OPERATOR_CHAIN_ID:-"cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f"}
# OPERATOR_CHAIN_ID=${OPERATOR_CHAIN_ID:-"5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191"}
OPERATOR_CHAIN_NODE=${OPERATOR_CHAIN_NODE:-"http://localhost:8888"}
# OPERATOR_CHAIN_NODE=${OPERATOR_CHAIN_NODE:-"https://kylin-dsp-1.liquidapps.io"}

OPERATOR_RESERVE_TOKEN=${OPERATOR_RESERVE_TOKEN:-"usdbthetoken"}
OPERATOR_RESERVE_RELAY=${OPERATOR_RESERVE_RELAY:-"usdb2eosrely"}
OPERATOR_RESERVE_SYMBOL=${OPERATOR_RESERVE_SYMBOL:-"USDB"}
OPERATOR_RESERVE_RELAY_SYMBOL=${OPERATOR_RESERVE_RELAY_SYMBOL:-"USDBSYS"}

CONTRACTS_DIR=${CONTRACTS_DIR:-"../ceo-core"}
CONTRACT_WASM_FILE=${CONTRACT_WASM_FILE:-"ceo-core.wasm"}
CONTRACT_ABI_FILE=${CONTRACT_ABI_FILE:-"ceo-core.abi"}

VACCOUNTS_PROVIDER=${VACCOUNTS_PROVIDER:-"heliosselene"}
VACCOUNTS_SERVICE=${VACCOUNTS_SERVICE:-"accountless1"}
# VACCOUNTS_PACKAGE=${VACCOUNTS_PACKAGE:-"accountless1"}
VACCOUNTS_PACKAGE=${VACCOUNTS_PACKAGE:-"default"}

VRAM_PROVIDER=${VRAM_PROVIDER:-"heliosselene"}
VRAM_SERVICE=${VRAM_SERVICE:-"ipfsservice1"}
# VRAM_PACKAGE=${VRAM_PACKAGE:-"package1"}
VRAM_PACKAGE=${VRAM_PACKAGE:-"default"}

VSTORAGE_PROVIDER=${VSTORAGE_PROVIDER:-"heliosselene"}
VSTORAGE_SERVICE=${VSTORAGE_SERVICE:-"liquidstorag"}
# VSTORAGE_PACKAGE=${VSTORAGE_PACKAGE:-"storage"}
VSTORAGE_PACKAGE=${VSTORAGE_PACKAGE:-"default"}

DAPP_STAKE_AMOUNT=${DAPP_STAKE_AMOUNT:-"100.0000 DAPP"}


CLEOS_COMMAND=${CLEOS_COMMAND:-"cleos"}
KEOSD_COMMAND=${KEOSD_COMMAND:-"keosd"}


# Reused variable to check for sub-shell errors
#
LAST_RESULT=""




# Logging helpers
#
function logbanner() {
    echo "+------------------------------------------------------------------------------------------"
    echo "| $1"
    echo "+------------------------------------------------------------------------------------------"
}

function loginfo() {
    echo "[operator-setup] INFO : $1"
}

function logerror() {
    echo "[operator-setup] ERROR: $1"
    echo ""
}

function logok() {
    echo "[operator-setup] INFO :  -> ok"
    echo ""
}

function quit_with_error() {
    logerror "$1"

    if [ ! -z "$2" ]
    then
        logerror "=================================================="
        echo "$2"
        logerror "=================================================="
    fi

    exit 1
}


# Main functions
#
function log_configuration() {
    loginfo "Configuration is: "
    loginfo " -> OPERATOR_ACCOUNT_NAME         = $OPERATOR_ACCOUNT_NAME"
    loginfo " -> OPERATOR_PRIVATE_KEY          = (shh... this is secret)"
    loginfo " -> OPERATOR_CHAIN_ID             = $OPERATOR_CHAIN_ID"
    loginfo " -> OPERATOR_CHAIN_NODE           = $OPERATOR_CHAIN_NODE"
    loginfo " -> OPERATOR_RESERVE_TOKEN        = $OPERATOR_RESERVE_TOKEN"
    loginfo " -> OPERATOR_RESERVE_RELAY        = $OPERATOR_RESERVE_RELAY"
    loginfo " -> OPERATOR_RESERVE_SYMBOL       = $OPERATOR_RESERVE_SYMBOL"
    loginfo " -> OPERATOR_RESERVE_RELAY_SYMBOL = $OPERATOR_RESERVE_RELAY_SYMBOL"
    loginfo " -> CONTRACTS_DIR                 = $CONTRACTS_DIR"
    loginfo " -> CONTRACT_WASM_FILE            = $CONTRACT_WASM_FILE"
    loginfo " -> CONTRACT_ABI_FILE             = $CONTRACT_ABI_FILE"
    loginfo " -> VACCOUNTS_PROVIDER            = $VACCOUNTS_PROVIDER"
    loginfo " -> VACCOUNTS_SERVICE             = $VACCOUNTS_SERVICE"
    loginfo " -> VACCOUNTS_PACKAGE             = $VACCOUNTS_PACKAGE"
    loginfo " -> VRAM_PROVIDER                 = $VRAM_PROVIDER"
    loginfo " -> VRAM_SERVICE                  = $VRAM_SERVICE"
    loginfo " -> VRAM_PACKAGE                  = $VRAM_PACKAGE"
    loginfo " -> VSTORAGE_PROVIDER             = $VSTORAGE_PROVIDER"
    loginfo " -> VSTORAGE_SERVICE              = $VSTORAGE_SERVICE"
    loginfo " -> VSTORAGE_PACKAGE              = $VSTORAGE_PACKAGE"
    loginfo " -> DAPP_STAKE_AMOUNT             = $DAPP_STAKE_AMOUNT"
    logok
}

function assert_cleos_command() {
    loginfo "Making sure cleos is installed"
    [ -z "$(command -v "$CLEOS_COMMAND")" ] && quit_with_error " -> Could not find cleos. Is it installed? (quitting)"
    logok
}

function assert_keosd_command() {
    loginfo "Making sure keosd is installed"
    [ -z "$(command -v "$KEOSD_COMMAND")" ] && quit_with_error " -> Could not find keosd. Is it installed? (quitting)"
    logok
}

function assert_keosd_is_running() {
    loginfo "Making sure keosd is running"
    [ -z "$(pgrep "$KEOSD_COMMAND")" ] && quit_with_error " -> Seems like keosd is not running. Make sure it's running before executing this setup script (quitting)"
    logok
}

function assert_eos_node() {
    loginfo "Making sure we can reach the EOS node"
    LAST_RESULT="$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" get info 2>&1)"
    [[ $? -ne 0 ]]                                && quit_with_error " -> Seems like we can't get info from the node (quitting)"
    [[ ! $LAST_RESULT = *"$OPERATOR_CHAIN_ID"* ]] && quit_with_error " -> The provided chain-id is different than the chain info we got (quitting)"
    logok
}

function assert_eos_tools() {
    assert_cleos_command
    assert_keosd_command
    assert_keosd_is_running
    assert_eos_node
}

function assert_account_name_exists() {
    loginfo "Making sure we have the operator account name"
    [ -z "$OPERATOR_ACCOUNT_NAME" ] && quit_with_error " -> Missing operator account name. Make sure OPERATOR_ACCOUNT_NAME is configured and accessible (quitting)"
    logok
}

function assert_account_on_node() {
    loginfo "Making sure account exists on chain"
    LAST_RESULT="$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" get account "$OPERATOR_ACCOUNT_NAME" 2>&1)"
    local LAST_EXIT_CODE=$?

    [[ $LAST_RESULT = *"Invalid name"* ]] && quit_with_error " -> Account name is invalid: $OPERATOR_ACCOUNT_NAME (quitting)"
    [[ $LAST_RESULT = *"unknown key"*  ]] && quit_with_error " -> Account not found on chain (quitting)"
    [ $LAST_EXIT_CODE -ne 0 ] && quit_with_error " -> Looks like we had an unknown error (quitting)" "$LAST_RESULT"
    logok
}

function assert_account() {
    assert_account_name_exists
    assert_account_on_node
}

function assert_private_key() {
    loginfo "Making sure we have the account private key"
    [ -z "$OPERATOR_PRIVATE_KEY" ] && quit_with_error " -> Missing operator private key. Make sure OPERATOR_PRIVATE_KEY is configured (quitting)"
    logok
}

function assert_dapp_tokens() {
    local DAPP_BALANCE

    loginfo "Making sure operator account has DAPP balance"
    DAPP_BALANCE="$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" get table dappservices "$OPERATOR_ACCOUNT_NAME" accounts | jq '.rows[0].balance')"
    [ "$DAPP_BALANCE" = "null" ] && quit_with_error " -> Account $OPERATOR_ACCOUNT_NAME does not have any DAPP balance (quitting)"
    logok
}

function create_temp_wallet() {
    local WALLET_NAME="operator-wallet"

    loginfo "Creating a temporary wallet for the setup"
    [ ! -z "$("$CLEOS_COMMAND" wallet list | grep "$WALLET_NAME")" ] &&  quit_with_error " -> Wallet already exists (quitting)"
    [   -f "$THIS_DIR/.temp_operator_wallet.pw"                    ] &&  quit_with_error " -> Wallet password file already exists (quitting)"

    LAST_RESULT=$("$CLEOS_COMMAND" wallet create --name $WALLET_NAME --file "$THIS_DIR/.temp_operator_wallet.pw" 2>&1)
    [ $? != 0 ] && quit_with_error " -> Seems like we had an unknown error (quitting)" "$LAST_RESULT"
    logok
}

function import_private_key() {
    local WALLET_NAME="operator-wallet"
    local LAST_EXIT_CODE

    loginfo "Importing private key into wallet"
    LAST_RESULT="$("$CLEOS_COMMAND" wallet import --name $WALLET_NAME --private-key "$OPERATOR_PRIVATE_KEY" 2>&1)"
    LAST_EXIT_CODE=$?
    [ $LAST_EXIT_CODE != 0 ] && [[ $LAST_RESULT != *"already exists"* ]] && quit_with_error " -> Seems like we had an unknown error (quitting)" "$LAST_RESULT"
    logok
}

function assert_abi_file() {
    loginfo "Making sure we have the ABI file"
    [ ! -f "$CONTRACTS_DIR/$CONTRACT_ABI_FILE" ] && quit_with_error " -> Could not find ABI file (quitting)"
    logok
}

function assert_wasm_file() {
    loginfo "Making sure we have the WASM file"
    [ ! -f "$CONTRACTS_DIR/$CONTRACT_WASM_FILE" ] && quit_with_error " -> Could not find WASM file (quitting)"
    logok
}

function assert_build_files() {
    assert_abi_file
    assert_wasm_file
}

function deploy() {

    # HACK: Use the same variable as a state-machine
    LAST_RESULT="TRY_DEPLOY"

    while true
    do
        case $LAST_RESULT in
            "TRY_DEPLOY")
                LAST_RESULT=$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" set contract "$OPERATOR_ACCOUNT_NAME" "$CONTRACTS_DIR" -p "$OPERATOR_ACCOUNT_NAME" 2>&1)
                continue;;

            *"eosio::setcode"*)
                loginfo " -> Contract deployed successfully"
                logok
                break;;

            *"insufficient ram"*)
                logerror " -> Not enough RAM (will try to buy)"
                LAST_RESULT=$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" system buyram "$OPERATOR_ACCOUNT_NAME" "$OPERATOR_ACCOUNT_NAME" "100.0000 $NATIVE_EOS_SYMBOL" -p "$OPERATOR_ACCOUNT_NAME" 2>&1)
                continue;;

            *"eosio::buyram"*)
                LAST_RESULT="TRY_DEPLOY"
                continue;;

            *"no balance object found"*)
                quit_with_error " -> Account does not have enough EOS tokens to deploy the contract (quitting)"
                ;;

            *)
                quit_with_error " -> Unknown error: " "$LAST_RESULT"
                ;;
        esac
    done
}

function open_eos_row() {
    loginfo "Making sure the account has a RAM row for the SYSTEM ($NATIVE_EOS_SYMBOL) token"
    LAST_RESULT=$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" push action eosio.token open "[\"$OPERATOR_ACCOUNT_NAME\", \"4,EOS\", \"$OPERATOR_ACCOUNT_NAME\"]" -p "$OPERATOR_ACCOUNT_NAME" 2>&1)
    [ $? -ne 0 ] && [[ "$LAST_RESULT" != *"Unknown action open"* ]] && quit_with_error " -> Could not open a RAM row for the SYSTEM ($NATIVE_EOS_SYMBOL) token" "$LAST_RESULT"
    logok
}

function open_reserve_row() {
    loginfo "Making sure the account has a RAM row for the RESERVE token"
    LAST_RESULT=$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" push action "$OPERATOR_RESERVE_TOKEN" open "[\"$OPERATOR_ACCOUNT_NAME\", \"$OPERATOR_RESERVE_SYMBOL\", \"$OPERATOR_ACCOUNT_NAME\"]" -p "$OPERATOR_ACCOUNT_NAME" 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not open a RAM row for the reserve currency" "$LAST_RESULT"
    logok
}

function init_contract() {
    loginfo "Initializing LiquidApps features on our contract"
    LAST_RESULT=$("$CLEOS_COMMAND" -u "$OPERATOR_CHAIN_NODE" push action "$OPERATOR_ACCOUNT_NAME" xvinit "[\"$OPERATOR_CHAIN_ID\"]" -p "$OPERATOR_ACCOUNT_NAME" 2>&1)
    [ $? -ne 0 ] && [[ ! $LAST_RESULT = *"already been set"* ]] && quit_with_error " -> Could not initialize LiquidApps features" "$LAST_RESULT"
    logok
}

function stake_dapp_tokens() {

    # vAccounts
    #
    loginfo "Selecting vAccounts package"
    LAST_RESULT=$("$CLEOS_COMMAND" -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"$VACCOUNTS_PROVIDER\",\"$VACCOUNTS_SERVICE\",\"$VACCOUNTS_PACKAGE\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not select vAccounts service package" "$LAST_RESULT"
    logok

    loginfo "Stake DAPP Tokens for vAccounts provider"
    LAST_RESULT=$("$CLEOS_COMMAND" -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"$VACCOUNTS_PROVIDER\",\"$VACCOUNTS_SERVICE\",\"$DAPP_STAKE_AMOUNT\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not stake DAPP tokens for vAccounts" "$LAST_RESULT"
    logok



    # vRAM
    #
    loginfo "Selecting vRAM package"
    LAST_RESULT=$("$CLEOS_COMMAND" -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"$VRAM_PROVIDER\",\"$VRAM_SERVICE\",\"$VRAM_PACKAGE\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not select vRAM service package" && "$LAST_RESULT"
    logok

    loginfo "Stake DAPP Tokens for vRAM provider"
    LAST_RESULT=$("$CLEOS_COMMAND" -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"$VRAM_PROVIDER\",\"$VRAM_SERVICE\",\"$DAPP_STAKE_AMOUNT\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not stake DAPP tokens for vRAM" "$LAST_RESULT"
    logok



    # vStorage
    #
    loginfo "Selecting vStorage package"
    LAST_RESULT=$("$CLEOS_COMMAND" -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"$VSTORAGE_PROVIDER\",\"$VSTORAGE_SERVICE\",\"$VSTORAGE_PACKAGE\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not select vStorage service package" && "$LAST_RESULT"
    logok

    loginfo "Stake DAPP Tokens for vStorage provider"
    LAST_RESULT=$("$CLEOS_COMMAND" -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"$VSTORAGE_PROVIDER\",\"$VSTORAGE_SERVICE\",\"$DAPP_STAKE_AMOUNT\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    [ $? -ne 0 ] && quit_with_error " -> Could not stake DAPP tokens for vStorage" "$LAST_RESULT"
    logok
}

function create_liquid_account_for_operator() {
    loginfo "Installing the push-liquid-action CLI tool"
    LAST_RESULT=$(npm i -g push-liquid-action 2>&1)
    [[ $? != 0 ]] && logerror "Could not install push-liquid-action CLI tool (quitting)\n" && echo "$LAST_RESULT\n" && exit 1
    logok

    loginfo "Creating a new LiquidAccount for the operator"
    LAST_RESULT=$(pla -u $OPERATOR_CHAIN_NODE $OPERATOR_ACCOUNT_NAME regaccount $OPERATOR_ACCOUNT_NAME $OPERATOR_PRIVATE_KEY 2>&1)
    [[ $? != 0 ]] && logerror "Could not create a LiquidAccount for the operator (quitting)\n" && echo "$LAST_RESULT\n" && exit 1
    logok
}

function start() {
    logbanner "Starting Operator Setup"
    log_configuration

    assert_eos_tools
    assert_account
    assert_private_key
    assert_dapp_tokens

    create_temp_wallet
    import_key_into_wallet

    assert_build_files
    deploy
    open_eos_row
    open_reserve_row
    init_contract

    stake_dapp_tokens
    create_liquid_account_for_operator

    logbanner "Operator Setup Complete!"
}



# Start
#

case "$1" in

    "assert-cleos")               assert_cleos_command       ;;
    "assert-keosd")               assert_keosd_command       ;;
    "assert-keosd-is-running")    assert_keosd_is_running    ;;
    "assert-eos-node")            assert_eos_node            ;;
    "assert-account-name-exists") assert_account_name_exists ;;
    "assert-account-on-node")     assert_account_on_node     ;;
    "assert-private-key")         assert_private_key         ;;
    "assert-dapp-tokens")         assert_dapp_tokens         ;;
    "create-temp-wallet")         create_temp_wallet         ;;
    "import-private-key")         import_private_key         ;;
    "assert-abi-file")            assert_abi_file            ;;
    "assert-wasm-file")           assert_wasm_file           ;;
    "deploy")                     deploy                     ;;
    "open-eos-row")               open_eos_row               ;;
    "open-reserve-row")           open_reserve_row           ;;
    "init-contract")              init_contract              ;;

    *) start ;;
esac
