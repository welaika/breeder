#!/bin/bash
# Set a new vhost in LAMP for Linux for developing purpose
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
#
# Nothing to configure here anyway. Enjoy

##############################################################################

init

load_libs
require_root_user
source_or_create_vhostrc
manage_arguments

create_project_folder
create_vhost_file
update_etc_hosts
create_database
reload_apache

bootstrap_wordless

##############################################################################

function init(){
  localweb=${docroot}
  site=${site}${firstleveldomain}
  folder=${localweb}/${site}
  vhostConf="${apacheconfpath}/${site}"
  [[ $wordless_locale -ne '' ]] || wordless_locale='it_IT';
}

function load_libs() {
  for lib in `ls ./lib`; do
    source $lib
  done
}

function require_root_user() {
  if [ "$(id -u)" != "0" ]; then
     error "This script must be run as root" 1>&2
     exit 1
  fi
}

function source_or_create_vhostrc() {
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
}

function manage_arguments(){
  if [[ $# -eq 0 ]]; then
      error 'Shit we have no arguments here, bro!'
      usage
  fi

  while getopts "s:da:iwL:" opt; do
      case $opt in
          i) init_rc $hostrcfile ;;
          s) site=$OPTARG ;;
          d) dbcreate=true ;;
          a) firstleveldomain=$OPTARG ;;
          w) wordless=true ;;
          L) wordless_locale=$OPTARG ;;
          *) usage ;;
      esac
  done
}

function create_project_folder(){
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
}

function update_etc_hosts() {
  if [[ ! $(grep ${site} /etc/hosts) ]]; then
    info "Writing '${site}' in /etc/hosts"
    echo "127.0.0.1 $site" >> /etc/hosts
  else
    info "'${site}' is already in the /etc/hosts file"
  fi
}

function create_database() {
  if [[ $dbcreate ]]; then
    dbname=${db_prefix}$(basename ${site} ${firstleveldomain})
    info "Creting database '${dbname}'..."

    if [[ ${mysqlpwd} ]]; then
        ${mysqlcmd} -u ${mysqluser} -p${mysqlpwd} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
    else
      ${mysqlcmd} -u ${mysqluser} -e "CREATE DATABASE IF NOT EXISTS ${dbname}"
    fi
    # echo $?
    if [[ $? != 0 ]]; then
      error "Cannot create database '${dbname}', please create in manually"
    else
      success "Database created"
    fi
  fi
}

function reload_apache() {
  info "Reloading Apache server..."
  ${apachecmd} reload 1>&2>&/dev/null
  if [[ $? == 0 ]]; then
    success "Done"
  else
    error "Could't reload apache executing '${apachecmd}'"
  fi
}

function bootstrap_wordless() {
  info "Bootstrapping WordLess..."
  wordless
  if [[ $? == 0 ]]; then
    success "Done"
  else
    error "Error occurred"
  fi
}

# Coding the project...it's your turn now
