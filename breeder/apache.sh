function reload_apache() {
	info "Reloading Apache server..."
	${apachecmd} reload 1>&2>&/dev/null

	if_error "Could't reload apache executing '${apachecmd}'"
}
