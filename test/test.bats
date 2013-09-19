#!/usr/bin/env bats

load test_helper
fixtures suite

@test "installed" {
	
	run bats "$FIXTURE_ROOT/installed.bats"
	[ $status -eq 0 ]

}
