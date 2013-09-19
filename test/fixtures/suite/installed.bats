#!/usr/bin/env bats

@test "is installed" {
	[ -d /usr/local/lib/breeder ]
	[ -f /usr/local/bin/breeder ]
}

@test "executable in path" {
	[ -x $(which breeder) ]
}
