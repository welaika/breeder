fixtures() {
	FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
}

setup() {
	export TMP="$BATS_TEST_DIRNAME/tmp"
	export PREFIX=$TMP

	(
		pushd $BATS_TEST_DIRNAME/../
		make install
		popd
	) > /dev/null

	export PATH="$TMP/bin/:$PATH"
}

teardown() {
	rm -rf "$TMP"
}
