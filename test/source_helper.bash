slib() {
	source $BR_LIB/$1.sh
}

fakerc() {
	export userinput_config="$BATS_TEST_DIRNAME/fakerc"
	source $userinput_config
}
