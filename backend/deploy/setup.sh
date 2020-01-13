
# Just a handy reference to "this dir"
#
THIS_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"



# This are the env vars we need (defaults for test info on Kylin)
#
OPERATOR_ACCOUNT_NAME=${OPERATOR_ACCOUNT_NAME:-"dappletokens"}
OPERATOR_PRIVATE_KEY=${OPERATOR_PRIVATE_KEY:-"5KDF4rdDFKKnPHcTqfMaqYw72vEXtv7rEZLy9rj4YyrjGfaAV6L"}
OPERATOR_CHAIN_ID=${OPERATOR_CHAIN_ID:-"5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191"}
OPERATOR_CHAIN_NODE=${OPERATOR_CHAIN_NODE:-"https://kylin-dsp-1.liquidapps.io"}

OPERATOR_RESERVE_TOKEN=${OPERATOR_RESERVE_TOKEN:-"usdbthetoken"}
OPERATOR_RESERVE_RELAY=${OPERATOR_RESERVE_RELAY:-"usdb2eosrely"}
OPERATOR_RESERVE_SYMBOL=${OPERATOR_RESERVE_SYMBOL:-"USDB"}
OPERATOR_RESERVE_RELAY_SYMBOL=${OPERATOR_RESERVE_RELAY_SYMBOL:-"USDBSYS"}



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

function log_configuration() {
    loginfo "Configuration is: "
    loginfo " -> OPERATOR_CHAIN_ID             = $OPERATOR_CHAIN_ID"
    loginfo " -> OPERATOR_CHAIN_NODE           = $OPERATOR_CHAIN_NODE\n"

    loginfo " -> OPERATOR_ACCOUNT_NAME         = $OPERATOR_ACCOUNT_NAME"
    loginfo " -> OPERATOR_PRIVATE_KEY          = (shh... this is hidden)\n"

    loginfo " -> OPERATOR_RESERVE_TOKEN        = $OPERATOR_RESERVE_TOKEN"
    loginfo " -> OPERATOR_RESERVE_SYMBOL       = $OPERATOR_RESERVE_SYMBOL\n"

    loginfo " -> OPERATOR_RESERVE_RELAY        = $OPERATOR_RESERVE_RELAY"
    loginfo " -> OPERATOR_RESERVE_RELAY_SYMBOL = $OPERATOR_RESERVE_RELAY_SYMBOL\n"
}



# Main functions
#
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
        logerror " -> Missing operator private key. Make sure OPERATOR_PRIVATE_KEY is configured and accessible (quitting)\n"
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
        logerror " -> Something broke: $LAST_RESULT"
        exit 1
    else
        logok
    fi


    loginfo "Importing private key into wallet"
    LAST_RESULT=$(cleos -u "$OPERATOR_CHAIN_NODE" wallet import --name $WALLET_NAME --private-key "$OPERATOR_PRIVATE_KEY" 2>&1)

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

function deploy() {
    loginfo "Deploying contract"

    if [ ! -f "$THIS_DIR/Operator.abi" ]
    then
        logerror " -> Could not find ABI file (quitting)\n"
        exit 1
    elif [ ! -f "$THIS_DIR/Operator.wasm" ]
    then
        logerror " -> Could not find WASM file (quitting)\n"
        exit 1
    fi


    LAST_RESULT=$(cleos -u $OPERATOR_CHAIN_NODE set contract $OPERATOR_ACCOUNT_NAME $THIS_DIR -p $OPERATOR_ACCOUNT_NAME 2>&1)
    if [ $? -ne 0 ]
    then
        logerror " -> Could not deploy contract"
        logerror "=================================================="
        echo "\n$LAST_RESULT\n"
        logerror "=================================================="

        exit 1
    else
        logok
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
    loginfo "Staking DAPP tokens for vRAM, vAccounts, vStorage"

    # # vAccounts
    cleos -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"heliosselene\",\"accountless1\",\"default\"]" -p $OPERATOR_ACCOUNT_NAME &>/dev/null
    cleos -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"heliosselene\",\"accountless1\",\"100.0000 DAPP\"]" -p $OPERATOR_ACCOUNT_NAME &>/dev/null

    # # vRAM
    cleos -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"heliosselene\",\"ipfsservice1\",\"default\"]" -p $OPERATOR_ACCOUNT_NAME &>/dev/null
    cleos -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"heliosselene\",\"ipfsservice1\",\"100.0000 DAPP\"]" -p $OPERATOR_ACCOUNT_NAME &>/dev/null

    # # vStorage
    cleos -u $OPERATOR_CHAIN_NODE push action dappservices selectpkg "[\"$OPERATOR_ACCOUNT_NAME\",\"heliosselene\",\"liquidstorag\",\"default\"]" -p $OPERATOR_ACCOUNT_NAME &>/dev/null
    cleos -u $OPERATOR_CHAIN_NODE push action dappservices stake "[\"$OPERATOR_ACCOUNT_NAME\",\"heliosselene\",\"liquidstorag\",\"100.0000 DAPP\"]" -p $OPERATOR_ACCOUNT_NAME &>/dev/null

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
    create_temp_wallet

    # Deploy our contract
    #
    deploy
    init_contract

    # Stake the DAPP tokens
    #
    stake_dapp_tokens

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