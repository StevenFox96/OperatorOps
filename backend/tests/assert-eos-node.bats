#!/usr/bin/env bats

@test "Fails if EOS is not reachable" {
    run bash -c "OPERATOR_CHAIN_NODE=foo ../deploy/setup.sh assert-eos-node"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "can't get info from the node")" ]
    [   -z "$(echo "$output" | grep "ok")"                           ]
}

@test "Fails on chain-id mismatchreachable" {
    run bash -c "OPERATOR_CHAIN_ID=foo ../deploy/setup.sh assert-eos-node"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "chain-id is different")" ]
    [   -z "$(echo "$output" | grep "ok")"                    ]
}

@test "Works if EOS is reachable" {
    run bash -c "OPERATOR_CHAIN_ID=cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f OPERATOR_CHAIN_NODE=http://localhost:13015 ../deploy/setup.sh assert-eos-node"

    [ $status = 0 ]
    [   -z "$(echo "$output" | grep "can't get info from the node")" ]
    [ ! -z "$(echo "$output" | grep "ok")"                           ]
}

