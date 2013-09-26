#!/usr/bin/env bats

load test_helper
load source_helper

@test "init.sh - manage_arguments() - warn if no arguments" {
	slib logger
	slib usage
	slib init
	run manage_arguments
	[[ "${lines[0]}" == $( error "Shit we have no arguments here, bro!" ) ]]
}

@test "init.sh - source_or_create_config() - config is sourced if exists" {
	fakerc
	slib logger
	slib init

	run source_or_create_config
	[[ $THIS_IS == 'FAKE' ]]
}

@test "init.sh - set_variables() - variables are parsed" {
	fakerc
	slib init
	userinput_domain_secondlevel='fakedomain'

	set_variables
	[[ "$folder" == "$TMP/www/fakedomain.local" ]]
}

@test "init.sh - set_variables() - \$folder is set to 'EMPTY' if domain_firstlevel=''" {
	fakerc
	slib init

	domain_firstlevel=''

	set_variables
	[[ "$folder" == 'EMPTY' ]]
}

@test "init.sh - set_variables() - \$folder is set to 'EMPTY' if localweb=''" {
	fakerc
	slib init

	docroot=''

	set_variables
	[[ "$folder" == 'EMPTY' ]]
}

@test "init.sh - require_root_user()" {
	slib logger
	slib init

	run require_root_user
	[[ "${lines[0]}" == $( error "This script should be run as root. Probably it will fail" ) ]]
}

@test "init.sh - init_config() - config initialized if not exists" {
	slib logger
	slib init
	userinput_config="$TMP/fakerc"

	run init_config

	[[ -s "$TMP/fakerc" ]]
}

@test "init.sh - create_project_folder() - folder is created if not exists" {
	fakerc
	slib logger
	slib init

	folder="$TMP/www/fakedomain.local"

	create_project_folder
		INFO=( $(stat -Lc "%a %G %U" $folder) )
		PERM=${INFO[0]}
		GROUP=${INFO[1]}
		OWNER=${INFO[2]}

	[[ -d "$TMP/www/fakedomain.local" ]]
	[[ $PERM == '770' ]]
	[[ $GROUP == $web_group ]]
	[[ $OWNER == $(id -un) ]]
}

@test "init.sh - create_project_folder() - folder isn't created if site's domain EMPTY" {
	fakerc
	slib logger
	slib init

	folder='EMPTY'
	run create_project_folder
	[ "$status" -ne 0 ]
}

@test "init.sh - br_user() - return my current username" {
	slib init

	run br_user
	[[ "$output" == $(id -un) ]]
}
