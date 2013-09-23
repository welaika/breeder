#!/bin/bash

# Set a new vhost in LAMP for Linux for developing purpose
#
# .vhostrc is adaptable for XAMPP/MAMPP. Just add in your
# /opt/lampp/etc/httpd.conf a section like this:
#
#   # Virtual hosts
#   Include etc/extra/httpd-vhosts.conf #Already present by deafult
#   Include etc/extra/sites-enabled/*
#
# and create such dir:
#
#   mkdir /opt/lampp/etc/extra/sites-enabled/
#
# then configure your $HOME/.vhostrc accordingly
#
# Nothing to configure here anyway. Enjoy

##############################################################################

## Properties

BR_PREFIX=${PREFIX:-/usr/local}
BR_LIB="$BR_PREFIX/lib/breeder"
BR_BIN="$BR_PREFIX/bin/breeder"
BR_INTERACTIVE=${BR_INTERACTIVE:-true}

# Nexts are grabbed from command line
domain=''
domain_secondlevel=''
vhostconf=''
configfile=''
wordless_locale=''
folder=''

# Nexts are grabbed from conf file
localweb=''
domain_firstlevel=''
apachecmd=''
apacheconfpath=''
web_group=''
logdir=''
mysqlcmd=''
mysqlpwd=''
mysqluser=''
db_prefix=''

###################

function load_libs() {
	if [[ ! -d ${BR_LIB} ]]; then
		echo 'WARNING: Breeder is not installed. You should `sudo make install`'
		echo '	and use the `breeder` command instead of invoke it directly'
		exit 1
	fi

	for lib in `find ${BR_LIB} -name '*.sh'`; do
		source $lib
	done
}

##############################################################################

load_libs

# Passing all the arguments to the initializer
initialize $@

require_root_user

create_project_folder
create_vhost_file
update_etc_hosts
update_database
reload_apache

bootstrap_wordless

##############################################################################

# Coding the project...it's your turn now
