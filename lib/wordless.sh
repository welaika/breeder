function wordless(){
  if [[ ! -x `sudo -u $SUDO_USER bash -l -c "which wordless"` ]]; then
	warning "You need wordless gem installed in order to bootstrap a new"
	warning "WordLess project"

	exit 1
  fi

  sudo -u $SUDO_USER bash -l -c "wordless new $folder --locale=$wordless_locale"
}