#!/bin/bash
# shellcheck disable=SC2155
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2154
# shellcheck disable=SC2128
# shellcheck disable=SC2034
# shellcheck disable=SC2207
#===== FUNCTION ===========================================================
# NAME: unset_guest_values
# DESCRIPTION: Unset a certain value from the guests array
# PARAMS: 2
# 	$1 -> value to delete
# EXAMPLE:
#	array=(1 2 3 4)
#	unset_guests_value 2
#	echo ${array[@]} -> 1 3 4
# RETURNS: array[]
#==========================================================================
function unset_guest_value() {
	local IFS=$'\n'
	local value_to_delete="$1"

	# Loop over the array to find the value and then unset it
	for i in "${!guests[@]}"; do
		[[ "$i" == "$value_to_delete" ]] && {  unset "guests[$i]" && continue; }
		echo $?
	done
}

#===== FUNCTION ===========================================================
# NAME: display_info
# DESCRIPTION: Display whether is a WARNING|ERROR|INFO message
# PARAMS: 1
# 	$1 -> --warning|--error|--info
#   $2 -> message
# EXAMPLE:
#   display_info --warning "This is a warning message" -> [ WARNING ] This is a warning message
# RETURNS: formatted message
#==========================================================================
function display_info() {
        # Variables
        local msg_header

        # Parameter check
        case "$1" in
                --warning)
                        msg_header="[ ${bold_yellow}WARNING${reset} ]"
                        echo -e "$msg_header $2"
                        ;;
                --error)
                        msg_header="[ ${bold_red}ERROR${reset} ]"
                        echo -e "$msg_header $2"
						;;
                --info) msg_header="[ ${bold_green}INFO${reset} ]"
                        echo -e "$msg_header $2"
                        ;;
        esac
}

#===== FUNCTION ==========================================================
# NAME: fancy_waiter
# DESCRIPTION: Dsiplay a simple animation while waiting a process
# PARAMS: 3
#	$1 -> process_pid
#	$2 -> wait_msg
#	$3 -> error_msg
# EXAMPLE:
#	fancy_waiter 1234 "Foo is processing" "Foo failed"
#	-> (while 1234 pid exists) "Foo is processing"
#=========================================================================
function fancy_waiter() {
	tput civis # Hide cursor
	local process_pid="$1"
	local msg="$2"
	local err_msg="$3"
	local exit_code=0

	! [[ "$process_pid" =~ ^[0-9]+$ ]] && { display_info --error "$err_msg" && return 1; }

	tput sc # Save cursor position
	while ps ax -o pid | grep -q "$process_pid"; do
		for c in "|" "/" "-" "\\"; do
			echo -en "$wait_msg"
			tput rc # Restore cursor position
			sleep 0.2
		done
	done

	# Grab exit code from process
	wait "$process_pid"
	exit_code="$?"

	# Clear current line when finished
	echo -e "\e[K"
	tput cnorm # Set cursor visible again
	return $exit_code
}

#===== FUNCTION ============================================================
# NAME: get_pid
# DESCRIPTION: Get PID from process name
# PARAMS: 1
#	$1 -> process_name
# EXAMPLE:
#	get_pid "bash" -> 1234
#===========================================================================
function get_pid() {
	local process_name="$1"
	local pid="$(ps ax -o pid,command | grep -v grep | grep "$process_name" | awk '{ print $1 }')"

	if ! [[ "$pid" ]]; then
		display_info --error "Process \"$process_name\" not found"
		return 1
	else
		echo "$pid"
	fi
}
