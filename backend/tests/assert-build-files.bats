#!/usr/bin/env bats

@test "Failes if ABI file was not found" {
    run bash -c "CONTRACT_ABI_FILE=foo ../deploy/setup.sh assert-abi-file"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "not find ABI file")"  ]
    [   -z "$(echo "$output" | grep "ok")"                 ]
}

@test "Works with default ABI location" {
    run bash -c "../deploy/setup.sh assert-abi-file"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                 ]
    [   -z "$(echo "$output" | grep "not find ABI file")"  ]
}

@test "Failes if WASM file was not found" {
    run bash -c "CONTRACT_WASM_FILE=foo ../deploy/setup.sh assert-wasm-file"

    [ $status = 1 ]
    [ ! -z "$(echo "$output" | grep "not find WASM file")"  ]
    [   -z "$(echo "$output" | grep "ok")"                 ]
}

@test "Works with default WASM location" {
    run bash -c "../deploy/setup.sh assert-wasm-file"

    [ $status = 0 ]
    [ ! -z "$(echo "$output" | grep "ok")"                 ]
    [   -z "$(echo "$output" | grep "not find WASM file")"  ]
}
