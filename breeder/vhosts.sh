function init_rc() {

	if [[ -s $hostrcfile ]]; then
		warning "already initialized"
		exit 1;
	fi

	cat ${BR_LIB}/vhostrc >> $1

	chown br_user:br_user $1
	success ".vhostrc file created in your home"
	exit 0
}

# Write the vhost standalone conf file
function create_vhost() {
	local docroot=$2
	local site=$3
	local logdir=$4

	cat >> $1 <<EOT
<VirtualHost *:80>
	ServerAdmin $serveradmin
	ServerName $site

	DocumentRoot ${docroot}/${site}
	<Directory ${docroot}/${site}>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		Allow from all
	</Directory>

	ErrorLog ${logdir}/${site}.error.log
	# Possible values include: debug, info, notice, warn, error, crit, alert,
	# emerg.
	LogLevel debug
	CustomLog ${logdir}/${site}.access.log combined
</VirtualHost>
EOT
}

function create_vhost_file() {
	if [[ ! -f $vhostConf ]]; then
		info "Creating VHost file..."
		create_vhost $vhostConf $localweb $site $logdir

		if [[ -f $vhostConf ]]; then
			success "VHost correctly created"
		else
			error "VHost could not be created, aborting..."
			exit 1
		fi
	else
		info "VHost file already exists"
	fi
}

