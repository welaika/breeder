#!/usr/bin/env bats

load test_helper
load source_helper

@test "etc_hosts.sh - update_etc_hosts() - host entry is correctly written at the EOF" {
	slib logger
	slib etc_hosts

	export domain="fakedomain.local"
	run update_etc_hosts $domain "$TMP/hosts"

	export domain="fakedomain2.local"
	run update_etc_hosts $domain "$TMP/hosts"

	[[ "$(tail -n 1 $TMP/hosts)" == "127.0.0.1 fakedomain2.local" ]]
}
