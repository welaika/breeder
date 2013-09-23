function initialize() {
	manage_arguments $@
	source_or_create_vhostrc
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
			i) i_flag=true ;;
			d) dbcreate=true ;;
			w) wordless=true ;;
			h) usage ;;
			*) usage ;;
		esac
	done
}

function source_or_create_vhostrc() {
	config=${userinput_config:-"$HOME/.vhostrc"}

	if [[ ! -f ${config} ]]; then
		warning "Cannot find a .vhostrc file in $HOME"
		[[ $BR_INTERACTIVE == "true" ]] && (

			question "Would you like to create one [Y/n]"
			read answer

			if [[ ${answer} == "Y" || ${answer} == "y" || ${answer} == '' ]]; then
				init_config $config
				if [[ -s $config ]]; then
					success "rc file correctly created"
					info "Please configure the options in .vhostrc in your home dir"
					exit 0
				else
					error "Cannot proceed"
					exit 1
				fi
			fi

		)
	else
		source ${config}
	fi
}

function set_variables() {
	localweb=${docroot}
	vhostconf="${apacheconfpath}/${domain}"
	domain_secondlevel=${userinput_domain_secondlevel}
	[[ $userinput_domain_firstlevel ]] && domain_firstlevel=$userinput_domain_firstlevel;
	domain="${domain_secondlevel}.${domain_firstlevel}"
	[[ $localweb && $domain ]] && folder="${localweb}/${domain}" || folder='EMPTY'
	[[ $wordless_locale -ne '' ]] || wordless_locale='it_IT';
	[[ $i_flag ]] && config_to_be_inititialized=true;
}

function require_root_user() {
	if [ "$(id -u)" != "0" ]; then
		error "This script should be run as root. Probably it will fail" 1>&2
		return 1
	fi

	return 0
}

function init_config() {
	[[ $config_to_be_inititialized ]] || return 0

	if [[ -s $1 ]]; then
		warning "already initialized"
		exit 1;
	fi

	cat ${BR_LIB}/vhostrc >> $1

	chown $(br_user):$(br_user) $1
	success ".vhostrc file created in your home"
	exit 0
}


function create_project_folder() {
	if [[ $folder == 'EMPTY' ]]; then
		error 'There si a problem with your project folder path. Please check "docroot" config in your .vhostrc'
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
