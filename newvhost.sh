#!/bin/bash
# Set a new vhost in lamp for Linux
# .vhostrc is adaptable for LAMPP. Just add in your
# /opt/lampp/etc/httpd.conf a section like this:
#
# # Virtual hosts
# Include etc/extra/httpd-vhosts.conf
# Include etc/extra/sites-enabled/*
#
# and create such dir:
# mkdir /opt/lampp/etc/extra/sites-enabled/


function usage {
  echo "Usage: $(basename $0) -s example [options]"
  echo "Possible options are:"
  echo "    -s mysitename (mandatory, without first level domain)"
  echo "    -a '.com' (is your first level domain, default is defined in .vhostrc)"
  echo "    -d activate creation of a new DB"
  echo "    -i initialize creating .vhostrc file"
  echo "    -l activate symlinking from custom DocRoot to Apache DocRoot (deprecated)"

  exit 1
}

function init_rc() {

if [[ -s $hostrcfile ]]; then
  warning "already initialized"
  exit 1;
fi

  cat >> $1 << EOT
# Configuration file for newvhost script
#
# .vhostrc is adaptable for LAMPP. Just add in your
# /opt/lampp/etc/httpd.conf a section like this:
#
# # Virtual hosts
# Include etc/extra/httpd-vhosts.conf
# Include etc/extra/sites-enabled/*
#
# and create such dir:
# mkdir /opt/lampp/etc/extra/sites-enabled/

# Example configuration is based upon a Apache2 installation on Ubuntu Oneiric

# Path to the vhosts folder [ NO TRAILING SLASH ]
apacheconfpath='/etc/apache2/sites-enabled'

# the group of apache webserver ( and you must be in that group )
web_group="www-data"

# Directory in which apache will save log files [ NO TRAILING SLASH ]
logdir="/var/log"

# For symlinking from your custom DocRoot to the Apache DocRoot configure
# both the following options; esle just one of the two will be ok.
#
# The Apache document root
docroot="/var/www"
# Your custom document root
localweb=""

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

# Text color variables
txtred=$(tput setaf 1)  #Red
txtgre=$(tput setaf 2)  # Green
txtyel=$(tput setaf 3)  # Yellow
txtblu=$(tput setaf 4)  # Blue
txtbol=$(tput bold)     # Bold
txtres=$(tput sgr0)     # Reset

# Helper feedback functions
function info() {
  echo "${txtbol}    * ${1}${txtres}"
}
function success() {
  echo "${txtbol}${txtgre}   ** ${1}${txtres}"
}
function warning() {
  echo "${txtbol}${txtyel}  *** ${1}${txtres}"
}
function error() {
  echo "${txtbol}${txtred} **** ${1}${txtres}"
}
function question() {
  echo -n "${txtbol}${txtblu}    ? ${1}?${txtres} "
}

################################################################################

# Super User invocation required.
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   error "This script must be run as root" 1>&2
   exit 1
fi

hostrcfile="/home/${SUDO_USER}/.vhostrc"
if [[ ! -f ${hostrcfile} ]]; then
  warning "Cannot find a .vhostrc file in your (${SUDO_USER}) home folder"
  question "Would you like to create one [Y/n]"
  read answer

  if [[ ${answer} == "Y" || ${answer} == "y" || ${answer} == '' ]]; then
    init_rc $hostrcfile
    if [[ -s $hostrcfile ]]; then
      success "rc file correctly created"
      info "Please configure the options in .vhostrc in your home dir"
      exit 0
    else
      error "Cannot proceed"
      exit 1
    fi
  fi
else
  source ${hostrcfile}
fi

# Check for no arguments
if [[ $# -eq 0 ]]; then
    error 'Shit we have no arguments here, bro!'
    usage
fi

while getopts "s:lda:i" opt; do
    case $opt in
        i) init_rc $hostrcfile ;;
        s) site=$OPTARG ;;
        l) symlink=true ;;
        d) dbcreate=true ;;
        a) firstleveldomain=$OPTARG ;;
        *) usage ;;
    esac
done

if [[ ! $localweb ]]; then
  localweb=${docroot}
fi
site=${site}${firstleveldomain}
folder=${localweb}/${site}
vhostConf="${apacheconfpath}/${site}"


if [[ ! -d ${folder} ]]; then
  info "'${folder}' does not exists, creating..." 
  mkdir ${folder}

  if [[ -d ${folder} ]]; then  
    success "Folder correctly created"
  else
    error "Dear, I'm not able to create the site directory in your DocRoot. Go and create it, than retry!"
    error "e.g.: mkdir ${folder}"
    exit 1
  fi
else
  info "Folder '${folder}' already exists"
fi

chown ${SUDO_USER}:${web_group} $folder
chmod 770 $folder


if [[ ! -f $vhostConf ]]; then
  info "Creating VHost file..."
  create_vhost $vhostConf ${localweb} ${site} ${logdir}

  if [[ -f $vhostConf ]]; then
    success "VHost correctly created"
  else
    error "VHost could not be created, aborting..."
    exit 1
  fi
else
  info "VHost file already exists"
fi


if [[ $symlink ]]; then
  ln -s ${localweb}/${site} ${docroot}
fi


if [[ ! $(grep ${site} /etc/hosts) ]]; then
  info "Writing '${site}' in /etc/hosts"
  echo "127.0.0.1 $site" >> /etc/hosts
else
  info "'${site}' is already in the /etc/hosts file"
fi

if [[ $dbcreate ]]; then
  dbname=${db_prefix}$(basename ${site} ${firstleveldomain})
  info "Creting database '${dbname}'..."

  if [[ ${mysqlpwd} ]]; then
      ${mysqlcmd} -u ${mysqluser} -p${mysqlpwd} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
  elif [[ $dbcreate ]]; then
    ${mysqlcmd} -u ${mysqluser} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
  fi
  # echo $?
  if [[ $? != 0 ]]; then
    error "Cannot create database '${dbname}', please create in manually"
  else
    success "Database created"
  fi
fi

info "Reloading Apache server..."
${apachecmd} reload 1>&2>&/dev/null
if [[ $? == 0 ]]; then  
  success "Done"
else
  error "Could't reload apache executing '${apachecmd}'"
fi

