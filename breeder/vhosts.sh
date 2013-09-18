function init_rc() {

	if [[ -s $hostrcfile ]]; then
		warning "already initialized"
		exit 1;
	fi

	cat >> $1 << EOT
# Configuration file for newvhost script
#
# .vhostrc is adaptable for XAMPP/MAMPP. Just add in your
# /opt/lampp/etc/httpd.conf a section like this:
#
# # Virtual hosts
# Include etc/extra/httpd-vhosts.conf #Already present by deafult
# Include etc/extra/sites-enabled/*
#
# and create such dir:
# mkdir /opt/lampp/etc/extra/sites-enabled/
#
# then configure your $HOME/.vhostrc accordingly

# Example configuration is based upon a Apache2 installation on Ubuntu Oneiric

# Path to the vhosts folder [ NO TRAILING SLASH ]
apacheconfpath='/etc/apache2/sites-enabled'

# the group of apache webserver ( and you must be in that group )
web_group="www-data"

# Directory in which apache will save log files [ NO TRAILING SLASH ]
logdir="/var/log"

# The Apache document root
docroot="/var/www"

# The first level domain to be applied to all created vhosts
# default; used if no other is passed through relative flag
firstleveldomain='.local'
# Server administrator email
serveradmin="root@localhost"

# MySQL server access data
mysqluser="root"
mysqlpwd=""
# A prefix to be added to all database created
db_prefix=""

# The absolute path to the MySQL executable ( needed to create the database )
# Pay attention if you're using LAMPP: to have the executable in $PATH is your
# business
mysqlcmd=$(which mysql)
# Apache2 executable ( needed to restart apache )
apachecmd="service apache2"
EOT

	chown ${SUDO_USER}:${SUDO_USER} $1
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

