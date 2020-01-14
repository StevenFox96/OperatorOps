
# Just a handy reference to "this dir"
#
THIS_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"


# Keep a reference of sub-shell errors for better error-handling
#
LAST_RESULT=""



# This are the env vars we need (defaults for test info on Kylin)
#
OPERATOR_ACCOUNT_NAME=${OPERATOR_ACCOUNT_NAME:-""}
OPERATOR_PRIVATE_KEY=${OPERATOR_PRIVATE_KEY:-""}
OPERATOR_CHAIN_ID=${OPERATOR_CHAIN_ID:-"5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191"}
OPERATOR_CHAIN_NODE=${OPERATOR_CHAIN_NODE:-"https://kylin-dsp-1.liquidapps.io"}

OPERATOR_RESERVE_TOKEN=${OPERATOR_RESERVE_TOKEN:-"usdbthetoken"}
OPERATOR_RESERVE_RELAY=${OPERATOR_RESERVE_RELAY:-"usdb2eosrely"}
OPERATOR_RESERVE_SYMBOL=${OPERATOR_RESERVE_SYMBOL:-"USDB"}
OPERATOR_RESERVE_RELAY_SYMBOL=${OPERATOR_RESERVE_RELAY_SYMBOL:-"USDBEOS"}

CONTRACTS_DIR=${CONTRACTS_DIR:-"../ceo-core"}
CONTRACT_WASM_FILE=${CONTRACT_WASM_FILE:-"ceo-core.wasm"}
CONTRACT_ABI_FILE=${CONTRACT_ABI_FILE:-"ceo-core.abi"}

VACCOUNTS_PROVIDER=${VACCOUNTS_PROVIDER:-"heliosselene"}
VACCOUNTS_SERVICE=${VACCOUNTS_SERVICE:-"accountless1"}
VACCOUNTS_PACKAGE=${VACCOUNTS_PACKAGE:-"accountless1"}

VRAM_PROVIDER=${VRAM_PROVIDER:-"heliosselene"}
VRAM_SERVICE=${VRAM_SERVICE:-"ipfsservice1"}
VRAM_PACKAGE=${VRAM_PACKAGE:-"package1"}

VSTORAGE_PROVIDER=${VSTORAGE_PROVIDER:-"heliosselene"}
VSTORAGE_SERVICE=${VSTORAGE_SERVICE:-"liquidstorag"}
VSTORAGE_PACKAGE=${VSTORAGE_PACKAGE:-"storage"}

DAPP_STAKE_AMOUNT=${DAPP_STAKE_AMOUNT:-"100.0000 DAPP"}



# Reused variable to check for sub-shell errors
#
LAST_RESULT=""




# Logging helpers
#
function logbanner() {
    echo "\n+------------------------------------------------------------------------------------------"
    echo "| $1"
    echo "+------------------------------------------------------------------------------------------\n"
}

function loginfo() {
    echo "[operator-setup] INFO : $1"
}

function logerror() {
    echo "[operator-setup] ERROR: $1"
}

function logok() {
    loginfo " -> ok\n"
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

function assert_eos_tools() {

    # We need cleos
    loginfo "Making sure cleos is installed"
    if [ -z "$(command -v cleos)" ]
    then
        logerror " -> Could not find cleos. Is it installed? (quitting)\n"
        exit 1
    else
        logok
    fi

    # We need keosd
    loginfo "Making sure keosd is installed"
    if [ -z "$(command -v keosd)" ]
    then
        logerror " -> Could not find keosd. Is it installed? (quitting)\n"
        exit 1
    else
        logok
    fi


    # We need keosd running
    loginfo "Making sure keosd is running"
    if [ -z "$(pgrep keosd)" ]
    then
        logerror " -> Looks like keosd is not running. Make sure it's running before executing this setup script (quitting)\n"
        exit 1
    else
        logok
    fi


    # Last, make sure we can reach the EOS node
    loginfo "Making sure we can reach the EOS node"
    LAST_RESULT="$(cleos -u $OPERATOR_CHAIN_NODE get info)"
    if [ $? -ne 0 ]
    then
        logerror " -> Looks like we can't get info from the node (quitting)\n"
        exit 1
    elif [[ ! $LAST_RESULT = *"$OPERATOR_CHAIN_ID"* ]]
    then
        logerror " -> The provided chain-id is different than the chain info we got (quitting)\n"
        exit 1
    else
        logok
    fi
}

function assert_account() {
    loginfo "Making sure we have the operator account name"
    if [ -z "$OPERATOR_ACCOUNT_NAME" ]
    then
        logerror " -> Missing operator account name. Make sure OPERATOR_ACCOUNT_NAME is configured and accessible (quitting)\n"
        exit 1
    else
        loginfo " -> ok ($OPERATOR_ACCOUNT_NAME)\n"
    fi


    # Make sure it exists on the blockchain
    loginfo "Making sure account exists on chain"
    local LAST_RESULT=$(cleos -u "$OPERATOR_CHAIN_NODE" get account "$OPERATOR_ACCOUNT_NAME" 2>&1)

    if [[ $LAST_RESULT = *"Invalid name"* ]]
    then
        logerror " -> Account name is invalid: $OPERATOR_ACCOUNT_NAME (quitting)\n"
        exit 1
    elif [[ $LAST_RESULT = *"unknown key"* ]]
    then
        logerror " -> Account not found on chain (quitting)\n"
        exit 1
    fi

    if [ $? -ne 0 ]
    then
        logerror " -> Looks like we had an unknown error (quitting)\n"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi
}

function assert_private_key() {
    loginfo "Making sure we have the account private key"
    if [ -z "$OPERATOR_PRIVATE_KEY" ]
    then
        logerror " -> Missing operator private key. Make sure OPERATOR_PRIVATE_KEY is configured (quitting)\n"
        exit 1
    else
        logok
    fi
}

function assert_dapp_tokens() {
    loginfo "Making sure operator account has DAPP tokens"
    if [ -z "$(cleos -u $OPERATOR_CHAIN_NODE get table dappservices $OPERATOR_ACCOUNT_NAME accounts | jq '.rows[0].balance')" ]
    then
        logerror "Account $OPERATOR_ACCOUNT_NAME does not have any DAPP tokens (quitting)\n"
        exit 1
    else
        logok
    fi
}

function create_temp_wallet() {
    local WALLET_NAME="operator-wallet"

    loginfo "Creating a temporary wallet for the setup"
    LAST_RESULT=$(cleos -u "$OPERATOR_CHAIN_NODE" wallet create --name $WALLET_NAME --file "$THIS_DIR/.temp_operator_wallet.pw" 2>&1)

    if [ $? -ne 0 ]
    then
        logerror " -> Looks like we had an unknown error (quitting)\n"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi


    loginfo "Importing private key into wallet"
    LAST_RESULT=$(cleos -u "$OPERATOR_CHAIN_NODE" wallet import --name $WALLET_NAME --private-key "$OPERATOR_PRIVATE_KEY" 2>&1)

    if [ $? -ne 0 ] && [[ $LAST_RESULT != *"already exists"* ]]
    then
        logerror " -> Looks like we had an unknown error (quitting)\n"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi
}

function deploy() {
    loginfo "Deploying contract"

    loginfo " -> Making sure we have the ABI file"
    if [ ! -f "$CONTRACTS_DIR/$CONTRACT_ABI_FILE" ]
    then
        logerror " -> Could not find ABI file (quitting)\n"
        exit 1
    else
        logok
    fi
    
    loginfo " -> Making sure we have the WASM file"
    if [ ! -f "$CONTRACTS_DIR/$CONTRACT_WASM_FILE" ]
    then
        logerror " -> Could not find WASM file (quitting)\n"
        exit 1
    else
        logok
    fi
    loginfo " -> ok (all files found)\n"


    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE set contract $OPERATOR_ACCOUNT_NAME $CONTRACTS_DIR -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [[ $LAST_RESULT = *"net usage is too high"* ]]
    then
        loginfo " -> Looks like you don't have enough NET (will try to get some now)"
        $(cleos -u $OPERATOR_CHAIN_NODE system delegatebw $OPERATOR_ACCOUNT_NAME $OPERATOR_ACCOUNT_NAME "20.0000 EOS" "0.0000 EOS" -p $OPERATOR_ACCOUNT_NAME &>/dev/null)
        if [ $? -ne 0 ]
        then
            logerror " -> Could not get NET resources (quitting)\n"
            logerror "=================================================="
            echo "\n$LAST_RESULT\n"
            logerror "=================================================="

            exit 1
        else
            logok
        fi
    fi
    
    
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE set contract $OPERATOR_ACCOUNT_NAME $CONTRACTS_DIR -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [[ $LAST_RESULT = *"cpu usage is too high"* ]]
    then
        loginfo " -> Looks like you don't have enough CPU (will try to get some now)"
        $(cleos -u $OPERATOR_CHAIN_NODE system delegatebw $OPERATOR_ACCOUNT_NAME $OPERATOR_ACCOUNT_NAME "0.0000 EOS" "80.0000 EOS" -p $OPERATOR_ACCOUNT_NAME &>/dev/null)
        if [ $? -ne 0 ]
        then
            logerror " -> Could not get CPU resources (quitting)\n"
            logerror "=================================================="
            echo "\n$LAST_RESULT\n"
            logerror "=================================================="

            exit 1
        else
            logok
        fi
    fi
    
    
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE set contract $OPERATOR_ACCOUNT_NAME $CONTRACTS_DIR -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [[ $LAST_RESULT = *"more than allotted RAM"* ]]
    then
        loginfo " -> Looks like you don't have enough RAM (will try to get some now)"
        $(cleos -u $OPERATOR_CHAIN_NODE system buyram $OPERATOR_ACCOUNT_NAME $OPERATOR_ACCOUNT_NAME "100.0000 EOS" -p $OPERATOR_ACCOUNT_NAME &>/dev/null)
        if [ $? -ne 0 ]
        then
            logerror " -> Could not get RAM resources (quitting)\n"
            logerror "=================================================="
            echo "\n$LAST_RESULT\n"
            logerror "=================================================="

            exit 1
        else
            logok
        fi
    fi


    loginfo "Adding code permission to the account"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE set account permission $OPERATOR_ACCOUNT_NAME active --add-code 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not add code permission"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi

}

function init_contract() {
    loginfo "Making sure the account has a RAM row for the RESERVE token"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action $OPERATOR_RESERVE_TOKEN open "[\"$OPERATOR_ACCOUNT_NAME\", \"$OPERATOR_RESERVE_SYMBOL\", \"$OPERATOR_ACCOUNT_NAME\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not open a RAM row for the reserve token"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi


    loginfo "Making sure the account has a RAM row for the SYSTEM (EOS) token"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action eosio.token open "[\"$OPERATOR_ACCOUNT_NAME\", \"4,EOS\", \"$OPERATOR_ACCOUNT_NAME\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not open a RAM row for the SYSTEM (EOS) token"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi


    loginfo "Initializing LiquidApps features on our contract"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action $OPERATOR_ACCOUNT_NAME xvinit "[\"$OPERATOR_CHAIN_ID\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ] && [[ ! $LAST_RESULT = *"already been set"* ]]
    then
        logerror " -> Could not initialize LiquidApps features"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi
}

function stake_dapp_tokens() {

    # vAccounts
    #
    loginfo "Selecting vAccounts package"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"$VACCOUNTS_PROVIDER\",\"$VACCOUNTS_SERVICE\",\"$VACCOUNTS_PACKAGE\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not select vAccounts service package"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi

    loginfo "Stake DAPP Tokens for vAccounts provider"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"$VACCOUNTS_PROVIDER\",\"$VACCOUNTS_SERVICE\",\"$DAPP_STAKE_AMOUNT\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not stake DAPP tokens for vAccounts"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi




    # vRAM
    #
    loginfo "Selecting vRAM package"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"$VRAM_PROVIDER\",\"$VRAM_SERVICE\",\"$VRAM_PACKAGE\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not select vRAM service package"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi

    loginfo "Stake DAPP Tokens for vRAM provider"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"$VRAM_PROVIDER\",\"$VRAM_SERVICE\",\"$DAPP_STAKE_AMOUNT\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not stake DAPP tokens for vRAM"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi




    # vStorage
    #
    loginfo "Selecting vStorage package"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"$VSTORAGE_PROVIDER\",\"$VSTORAGE_SERVICE\",\"$VSTORAGE_PACKAGE\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not select vStorage service package"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi

    loginfo "Stake DAPP Tokens for vStorage provider"
    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"$VSTORAGE_PROVIDER\",\"$VSTORAGE_SERVICE\",\"$DAPP_STAKE_AMOUNT\"]" -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not stake DAPP tokens for vStorage"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
    fi
}

function create_liquid_account_for_operator() {
    loginfo "Installing the push-liquid-action CLI tool"
    LAST_RESULT=$(npm i -g push-liquid-action 2>&1)
    [[ $? != 0 ]] && logerror "Could not install push-liquid-action CLI tool (quitting)\n" && echo "$LAST_RESULT\n" && exit 1;
    logok


    loginfo "Creating a new LiquidAccount for the operator"
    LAST_RESULT=$(pla -u $OPERATOR_CHAIN_NODE $OPERATOR_ACCOUNT_NAME regaccount $OPERATOR_ACCOUNT_NAME $OPERATOR_PRIVATE_KEY 2>&1)
    [[ $? != 0 ]] && logerror "Could not create a LiquidAccount for the operator (quitting)\n" && echo "$LAST_RESULT\n" && exit 1;
    logok
}

function start() {
    logbanner "Starting Operator Setup"
    log_configuration


    # Start by making sure we have all the EOS tools & accounts we need
    #
    assert_eos_tools
    assert_account
    assert_private_key
    assert_dapp_tokens
    create_temp_wallet

    # Deploy our contract
    #
    deploy
    init_contract

    # Setup
    #
    stake_dapp_tokens
    create_liquid_account_for_operator

    # Done
    #
    logbanner "Operator Setup Complete!"
}



# Start
#

case "$1" in


    *)
        start
        ;;
esac
