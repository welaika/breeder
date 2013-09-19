fixtures() {
	FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
}

setup() {
	export TMP="$BATS_TEST_DIRNAME/tmp"
	export PREFIX=$TMP
	export BR_INTERACTIVE=0
	export BR_LIB="$PREFIX/lib/breeder"
	export BR_BIN="$PREFIX/bin/breeder"

	( pushd $BATS_TEST_DIRNAME/../; make install; popd ) > /dev/null

	export PATH="$TMP/bin/:$PATH"
}

teardown() {
	rm -rf "$TMP"
}

decho() {
	echo "# DEBUG:" $@ >&3
}
