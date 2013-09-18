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

function if_error() {
	local error_message=$2

	if [[ $? == 0 ]]; then
		success "Done"
	else
		error $error_message
	fi
}
