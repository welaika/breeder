#!/usr/bin/env bats

load test_helper
load source_helper

@test "vhosts.sh - create_vhost() - file is getting created" {
	fakerc
	slib vhosts

	site="fakedomain.local"
	file="$apacheconfpath/$site"
	run create_vhost $file $docroot $site $logdir

	[[ -s $apacheconfpath/$site ]]
}

@test "vhosts.sh - create_vhost() - file has expexted parameters" {
	fakerc
	slib vhosts

	site="fakedomain.local"
	file="$apacheconfpath/$site"
	run create_vhost $file $docroot $site $logdir

	[[ `grep $docroot $file` ]]
	[[ `grep $site $file` ]]
	[[ `grep $logdir $file` ]]
	[[ `grep $serveradmin $file` ]]
	[[ `grep $serveradmin $file` ]]
}

@test "vhosts.sh - create_vhost_file() - skip if existent" {
	slib logger
	slib vhosts

	touch $TMP/file
	vhostconf="$TMP/file"

	run create_vhost_file
	[[ "$output" == $( info "VHost file already exists" ) ]]
}

# vim: set ts=8 sts=8 sw=8 noet:

