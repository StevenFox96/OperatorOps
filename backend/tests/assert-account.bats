#!/usr/bin/env bats

@test "Fails if missing account name is empty" {
    run bash -c "OPERATOR_ACCOUNT_NAME= ../deploy/setup.sh assert-account-name-exists"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "Missing operator account name")" ]
    [   -z "$(echo "$output" | grep "ok")"                            ]
}

@test "Works if account name exists" {
    run bash -c "OPERATOR_ACCOUNT_NAME=foo ../deploy/setup.sh assert-account-name-exists"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                            ]
    [   -z "$(echo "$output" | grep "Missing operator account name")" ]
}

@test "Fails if account name is invalid" {
    run bash -c "OPERATOR_ACCOUNT_NAME=urithebadnameeeee ../deploy/setup.sh assert-account-on-node"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "name is invalid")" ]
    [   -z "$(echo "$output" | grep "ok")"              ]
}

@test "Fails if account name is not found on chain" {
    run bash -c "OPERATOR_ACCOUNT_NAME=urithedragun ../deploy/setup.sh assert-account-on-node"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "not found on chain")" ]
    [   -z "$(echo "$output" | grep "ok")"                 ]
}

@test "Works if account name exists on chain" {
    run bash -c "OPERATOR_ACCOUNT_NAME=urithedragon ../deploy/setup.sh assert-account-on-node"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                 ]
    [   -z "$(echo "$output" | grep "not found on chain")" ]
}
