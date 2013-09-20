function add_etc_hosts_entry() {
	local hostname=$1
	if [[ ! $(grep ${hostname} /etc/hosts) ]]; then
		info "Writing '${hostname}' in /etc/hosts"
		echo "127.0.0.1 $hostname" >> /etc/hosts
	else
		info "'${hostname}' is already in the /etc/hosts file"
	fi
}

function update_etc_hosts() {
	add_etc_hosts_entry $domain
}
