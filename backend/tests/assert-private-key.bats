#!/usr/bin/env bats

@test "Fails if missing private key" {
    run bash -c "OPERATOR_PRIVATE_KEY= ../deploy/setup.sh assert-private-key"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "Missing operator private key")" ]
    [   -z "$(echo "$output" | grep "ok")"                           ]
}

@test "Works if private key exists" {
    run bash -c "OPERATOR_PRIVATE_KEY=123 ../deploy/setup.sh assert-private-key"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                           ]
    [   -z "$(echo "$output" | grep "Missing operator private key")" ]
}

