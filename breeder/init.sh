function initialize() {
	manage_arguments $@
	source_or_create_config
	set_variables
	init_config $config
}

function manage_arguments(){
	if [[ $# -eq 0 ]]; then
		error 'Shit we have no arguments here, bro!'
		usage
	fi

	while getopts "s:da:iwc:L:h" opt; do
		case $opt in
			c) userinput_config=$OPTARG ;;
			s) userinput_domain_secondlevel=$OPTARG ;;
			a) userinput_domain_firstlevel=$OPTARG ;;
			L) wordless_locale=$OPTARG ;;
<<<<<<< HEAD
			i) i_flag=true ;;
=======
			i) init_config && exit 0 || exit 1 ;;
>>>>>>> debug
			d) dbcreate=true ;;
			w) wordless=true ;;
			h) usage ;;
			*) usage ;;
		esac
	done
}

function source_or_create_config() {
	config=${userinput_config:-"$HOME/.vhostrc"}

	if [[ ! -f ${config} ]]; then
		warning "Cannot find a .vhostrc file"

		[[ $BR_INTERACTIVE == "true" ]] && (
			question "Would you like to create one [Y/n]"
			read answer

			if [[ ${answer} == "Y" || ${answer} == "y" || ${answer} == '' ]]; then
				init_config
			fi
		)

		exit $?

	else
		source ${config}
	fi
}

function set_variables() {
	localweb=${docroot}
	domain_secondlevel=${userinput_domain_secondlevel}
	[[ $userinput_domain_firstlevel ]] && domain_firstlevel=$userinput_domain_firstlevel;
	domain="${domain_secondlevel}.${domain_firstlevel}"
	vhostconf="${apacheconfpath}/${domain}"
	[[ $localweb && $domain ]] && folder="${localweb}/${domain}" || folder='EMPTY'
	[[ $wordless_locale -ne '' ]] || wordless_locale='it_IT';
}

function require_root_user() {
	if [ "$(id -u)" != "0" ]; then
		error "This script should be run as root. Probably it will fail" 1>&2
		return 1
	fi

	return 0
}

function init_config() {
	config=${userinput_config:-"$HOME/.vhostrc"}

	if [[ -s $config ]]; then
		warning "already initialized"
		return 1;
	fi

	cat ${BR_LIB}/vhostrc >> $config

	chown $(br_user):$(br_user) $config

	if_error "Cannot proceed" && exit 1

	success "rc file correctly created"
	info "Please configure the options in .vhostrc in your home dir"
	exit 0
}


function create_project_folder() {
	if [[ $folder == 'EMPTY' ]]; then
		error 'There is a problem with your project folder path. Please check "docroot" config in your .vhostrc'
		exit 1
	fi

	if [[ ! -d ${folder} ]]; then
		info "'${folder}' does not exists, creating..."
		mkdir ${folder}

		if [[ -d ${folder} ]]; then
			chown $(br_user):${web_group} $folder
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

function br_user() {
	if [[ $SUDO_COMMAND ]]; then
		echo $SUDO_USER
	else
		echo $(whoami)
	fi
}
