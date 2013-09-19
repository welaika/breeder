#!/usr/bin/env bats

@test "is installed" {
	[ -d /usr/local/lin/breeder ]
	[ -e /usr/local/bin/breeder ]
}