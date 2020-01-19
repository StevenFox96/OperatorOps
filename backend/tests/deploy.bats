#!/usr/bin/env bats


TEST_ACCOUNT_NAME=""
TEST_PRIVATE_KEY=""
TEST_PUBLIC_KEY=""


setup() {
    # Make sure we don't have a temp-wallet from a previous test or something
    run bash -c "cleos wallet stop"
    run bash -c "rm -f ../deploy/.temp_operator_wallet.pw"
    run bash -c "rm -f ~/eosio-wallet/operator-wallet.wallet"
    run bash -c "cleos wallet list 3>&-"

    # Create a random account name
    TEST_ACCOUNT_NAME="$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z1-5' | fold -w 12 | head -n 1)"
    echo "# SETUP: test account created ($TEST_ACCOUNT_NAME)" >&3

    # Create new keys
    local KEYS="$(cleos create key --to-console)"
    TEST_PRIVATE_KEY="$(echo "$KEYS" | grep Private | awk '{print $3}')"
    TEST_PUBLIC_KEY="$(echo "$KEYS" | grep Public | awk '{print $3}')"

    # Create a freshly new temp wallet
    run bash -c "OPERATOR_PRIVATE_KEY=$TEST_PRIVATE_KEY ../deploy/setup.sh create-temp-wallet"
    run bash -c "OPERATOR_PRIVATE_KEY=$TEST_PRIVATE_KEY ../deploy/setup.sh import-private-key"

    # Import the eosio dev to our new wallet
    cleos wallet import --name operator-wallet --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 >/dev/null

    # Create the account on-chain
    cleos system newaccount --stake-net "1.0000 SYS" --stake-cpu "1.0000 SYS" --buy-ram "1.0000 SYS" --transfer eosio $TEST_ACCOUNT_NAME $TEST_PUBLIC_KEY >/dev/null
}

@test "Fails if not enough RAM (and no EOS to buy RAM with)" {
    run bash -c "OPERATOR_PRIVATE_KEY=$TEST_PRIVATE_KEY OPERATOR_ACCOUNT_NAME=$TEST_ACCOUNT_NAME NATIVE_EOS_SYMBOL=SYS ../deploy/setup.sh deploy"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "Not enough RAM")"       ]
    [ ! -z "$(echo "$output" | grep "not have enough EOS")"  ]
}

@test "Buys missing RAM if we have enough EOS's" {
    run bash -c "cleos push action eosio.token transfer '[\"eosio\", \"$TEST_ACCOUNT_NAME\", \"100.0000 SYS\", \"foo\"]' -p eosio"
    run bash -c "OPERATOR_PRIVATE_KEY=$TEST_PRIVATE_KEY OPERATOR_ACCOUNT_NAME=$TEST_ACCOUNT_NAME NATIVE_EOS_SYMBOL=SYS ../deploy/setup.sh deploy"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "Not enough RAM")"                 ]
    [ ! -z "$(echo "$output" | grep "Contract deployed successfully")" ]
}

