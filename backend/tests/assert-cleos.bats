#!/usr/bin/env bats

@test "Fails if cleos is not found" {
    run bash -c "CLEOS_COMMAND=FOO ../deploy/setup.sh assert-cleos"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "not find cleos")" ]
    [   -z "$(echo "$output" | grep "ok")"             ]
}

@test "Works if cleos is found" {
    run bash -c "CLEOS_COMMAND=cleos ../deploy/setup.sh assert-cleos"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"             ]
    [   -z "$(echo "$output" | grep "not find cleos")" ]
}

@test "Command name is 'cleos' by default" {
    run bash -c "../deploy/setup.sh assert-cleos"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"             ]
    [   -z "$(echo "$output" | grep "not find cleos")" ]
}




