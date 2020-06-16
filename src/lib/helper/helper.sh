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
