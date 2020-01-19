#!/usr/bin/env bats

@test "Fails if account doesn't have DAPP tokens" {
    run bash -c "OPERATOR_ACCOUNT_NAME=urithedragon ../deploy/setup.sh assert-dapp-tokens"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "does not have any DAPP balance")" ]
    [   -z "$(echo "$output" | grep "ok")"                             ]
}

@test "Works if account has DAPP tokens" {
    run bash -c "OPERATOR_ACCOUNT_NAME=urithetokens ../deploy/setup.sh assert-dapp-tokens"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep -e "ok")"                          ]
    [   -z "$(echo "$output" | grep "does not have any DAPP balance")" ]
}

