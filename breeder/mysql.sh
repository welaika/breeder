function create_database() {
	dbname=$1
	info "Creting database '${dbname}'..."

	if [[ ${mysqlpwd} ]]; then
		${mysqlcmd} -u ${mysqluser} -p${mysqlpwd} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
	else
		${mysqlcmd} -u ${mysqluser} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
	fi

	if_error "Cannot create database '${dbname}', please create in manually"
}

function update_database() {
	[[ $dbcreate ]] && create_database $domain_secondlevel
}

# vim: set ts=8 sts=8 sw=8 noet:

