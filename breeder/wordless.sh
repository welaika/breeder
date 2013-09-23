function wordless(){
	local user=$(br_user)
	if [[ ! -x `sudo -u $user bash -l -c "which wordless"` ]]; then
		warning "You need wordless gem installed in order to bootstrap a new"
		warning "WordLess project"

		exit 1
	fi

	pushd $folder > /dev/null
	sudo -u $user bash -l -c "wordless new $folder --locale=$wordless_locale"
	popd
}

function bootstrap_wordless() {
	if [[ $wordless ]]; then
		info "Bootstrapping WordLess..."
		wordless;
	fi
	if_error "Error occurred"
}
