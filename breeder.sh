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

BR_LIB='/usr/local/lib/breeder'
BR_BIN='/usr/local/bin/breeder'
# Nexts are grabbed from command line
localweb=''
site=''
folder=''
vhostConf=''
wordless_locale=''

###################

function load_libs() {
	if [[ ! -e /usr/local/bin/breeder && ! -d /usr/local/lib/breeder ]]; then
		echo 'WARNING: Breeder is not installed. You should `sudo make install`'
		echo '	and use the `breeder` command instead of invoke it directly'
		exit 1
	fi

	for lib in `find ${BR_LIB} -name '*.sh'`; do
		source $lib
	done
}

function set_variables() {
	localweb=${docroot}
	site=${site}${firstleveldomain}
	[[ $localweb && $site ]] && folder="${localweb}/${site}" || folder='EMPTY'
	vhostConf="${apacheconfpath}/${site}"
	[[ $wordless_locale -ne '' ]] || wordless_locale='it_IT';
}

function reload_apache() {
	info "Reloading Apache server..."
	${apachecmd} reload 1>&2>&/dev/null

	if_error "Could't reload apache executing '${apachecmd}'"
}


##############################################################################

load_libs
require_root_user

# Passing all the arguments to the initializer
initialize $@

create_project_folder
create_vhost_file
update_etc_hosts
update_database
reload_apache

bootstrap_wordless

##############################################################################

# Coding the project...it's your turn now
