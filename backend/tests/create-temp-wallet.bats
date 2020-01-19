#!/usr/bin/env bats

setup() {
    run cleos wallet stop
    run rm -f ../deploy/.temp_operator_wallet.pw
    run rm -f ~/eosio-wallet/operator-wallet.wallet
    run bash -c "cleos wallet list 3>&-"
}

@test "Errors if wallet is already loaded" {
    # First run creates it ok
    # Second run should fail
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "Wallet already exists")" ]
    [   -z "$(echo "$output" | grep "ok")"                    ]
}

@test "Errors if password file already exists" {
    # Create the password file
    touch ../deploy/.temp_operator_wallet.pw

    # Attempt to create wallet should fail
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "password file already exists")" ]
    [   -z "$(echo "$output" | grep "ok")"                    ]
}

@test "Errors wallet file (but not loaded)" {
    # First, create the wallet
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"

    # Then, restart keosd (with stop & list) and remove the .pw file
    run cleos wallet stop
    run rm -f ../deploy/.temp_operator_wallet.pw
    run bash -c "cleos wallet list 3>&-"

    # Try to create the wallet again (it should fail, because we still have a .wallet file)
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "Seems like we had an unknown error")" ]
    [ ! -z "$(echo "$output" | grep "Wallet already exists")"              ]
    [   -z "$(echo "$output" | grep "ok")"                                 ]
}

@test "Can create a temp wallet" {
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                                 ]
    [   -z "$(echo "$output" | grep "Seems like we had an unknown error")" ]
}

@test "Fails to import if private-key is invalid" {
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD4 ../deploy/setup.sh import-private-key"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "Invalid private key")" ]
    [   -z "$(echo "$output" | grep "ok")"                  ]
}

@test "Can import if private-key" {
    # First, create the wallet
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh create-temp-wallet"

    # Then, try to import the key
    run bash -c "OPERATOR_PRIVATE_KEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 ../deploy/setup.sh import-private-key"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                      ]
    [   -z "$(echo "$output" | grep "we had an unknown error")" ]
}

