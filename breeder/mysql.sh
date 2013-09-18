function create_database() {
	dbname=${db_prefix}$(basename ${site} ${firstleveldomain})
	info "Creting database '${dbname}'..."

	if [[ ${mysqlpwd} ]]; then
		${mysqlcmd} -u ${mysqluser} -p${mysqlpwd} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
	else
		${mysqlcmd} -u ${mysqluser} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
	fi

	if_error "Cannot create database '${dbname}', please create in manually"
}

function update_database() {
	[[ $dbcreate ]] && create_database
}