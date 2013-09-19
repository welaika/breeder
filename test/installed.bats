#!/usr/bin/env bats

load test_helper

@test "bin and lib installed" {
	run test -d "$BR_LIB" -a -f "$BR_BIN"
	[ "$status" -eq 0 ]
}

@test "breeder command in \$PATH" {
	run which breeder
	[ "$status" -eq 0 ]
}

