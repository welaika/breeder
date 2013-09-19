#!/usr/bin/env bats

load test_helper

@test "libraries are loaded" {
	rm -rf "$BR_LIB/*"
	echo "echo Libraries loaded && exit" > $BR_LIB/load.sh
	run breeder
	[ "${lines[0]}" = "Libraries loaded" ]
}
