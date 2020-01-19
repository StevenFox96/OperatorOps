#!/usr/bin/env bats

@test "Fails if keosd is not found" {
    run bash -c "KEOSD_COMMAND=FOO ../deploy/setup.sh assert-keosd"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "not find keosd")" ]
    [   -z "$(echo "$output" | grep "ok")"             ]
}

@test "Works if keosd is found" {
    run bash -c "KEOSD_COMMAND=keosd ../deploy/setup.sh assert-keosd"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"             ]
    [   -z "$(echo "$output" | grep "not find keosd")" ]
}

@test "Command for keosd name is 'keosd' by default" {
    run bash -c "../deploy/setup.sh assert-keosd"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"             ]
    [   -z "$(echo "$output" | grep "not find keosd")" ]
}

@test "Fails if keosd is not running" {
    run bash -c "cleos wallet stop"
    run bash -c "../deploy/setup.sh assert-keosd-is-running"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "keosd is not running")" ]
    [   -z "$(echo "$output" | grep "ok")"                   ]
}

