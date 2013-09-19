function initialize() {
	source_or_create_vhostrc
	manage_arguments $@
	set_variables
}

function manage_arguments(){
	if [[ $# -eq 0 ]]; then
		error 'Shit we have no arguments here, bro!'
		usage
	fi

	while getopts "s:da:iwL:h" opt; do
		case $opt in
			i) init_rc $hostrcfile ;;
			s) site=$OPTARG ;;
			d) dbcreate=true ;;
			a) firstleveldomain=$OPTARG ;;
			w) wordless=true ;;
			L) wordless_locale=$OPTARG ;;
			h) usage ;;
			*) usage ;;
		esac
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

function create_project_folder(){
	if [[ ! -d ${folder} ]]; then
		info "'${folder}' does not exists, creating..."
		mkdir ${folder}

		if [[ -d ${folder} ]]; then
			chown ${SUDO_USER}:${web_group} $folder
			chmod 770 $folder
			success "Folder correctly created"
		else
			error "Dear, I'm not able to create the site directory in your DocRoot. Go and create it, than retry!"
			error "e.g.: mkdir ${folder}"
			exit 1
		fi
	else
		info "Folder '${folder}' already exists"
	fi
}
