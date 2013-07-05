function add_etc_hosts_entry() {
	local s=$1

  if [[ ! $(grep ${s} /etc/hosts) ]]; then
    info "Writing '${s}' in /etc/hosts"
    echo "127.0.0.1 $s" >> /etc/hosts
  else
    info "'${s}' is already in the /etc/hosts file"
  fi
}