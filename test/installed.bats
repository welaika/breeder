#!/usr/bin/env bats

load test_helper

@test "is installed" {
	[ -d $BR_LIB ]
	[ -f $BR_BIN ]
}

@test "executable in path" {
	run which breeder
	[ "$status" -eq 0 ]
}
