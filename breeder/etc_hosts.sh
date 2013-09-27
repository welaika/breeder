function add_etc_hosts_entry() {
	local hostname=$1
	[[ $2 ]] && hostfile=$2 || hostfile="/etc/hosts"

	if [[ ! $(grep ${hostname} ${hostfile}) ]]; then
		info "Writing '${hostname}' in ${hostfile}"
		echo "127.0.0.1 $hostname" >> $hostfile
	else
		info "'${hostname}' is already in the /etc/hosts file"
	fi
}

function update_etc_hosts() {
	[[ $1 ]] && local hostname=$1 || local hostname=$domain
	[[ $2 ]] && local hostfile=$2
	add_etc_hosts_entry $hostname $hostfile
}

# vim: set ts=8 sts=8 sw=8 noet:

