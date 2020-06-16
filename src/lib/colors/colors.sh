#!/bin/bash
#==== COLORS ===========================================================
# NAME: colors.sh
# DESCRIPTION: Bash escape color secuences
#=======================================================================
# Text attributes
export bold="\e[1m"
export reset="\e[0m"
export underline="\e[4m"
export blink="\e[5m"
export dimm="\e[2m"

# Display normal colors
export red="\e[31m"
export green="\e[32m"
export yellow="\e[33m"
export blue="\e[34m"
export magenta="\e[35m"
export cyan="\e[36m"

# Display light colors
export light_gray="\e[37m"
export light_red="\e[91m"
export light_green="\e[92m"
export light_yellow="\e[93m"
export light_blue="\e[94m"
export light_magenta="\e[95m"
export light_cyan="\e[96m"
export white="\e[97m"

# Display bold colors
export bold_red="\e[1;31m"
export bold_green="\e[1;32m"
export bold_yellow="\e[1;33m"
export bold_blue="\e[1;34m"
export bold_magenta="\e[1;35m"
export bold_cyan="\e[1;36m"

#==== COLOR FUNCTION ===================================================
# NAME: random_color
# DESCRIPTION: Display a given message with a random color
# PARAMS: 1
#	$1 -> msg
# EXAMPLE:
#	random_color "This has a random color" -> (in "red") "This has..."
#=======================================================================
function random_color() {
	local msg="$1"
	local rc="3$(((RANDOM%6)+1))" # Generate a random number within the valid range (31, 32, 33...)
	echo -e "\e[${rc}m${msg}\e[0m"
}

#==== COLOR FUNCTION ===================================================
# NAME: bolder
# DESCRIPTION: Display the given message as bold text
# PARAMS: 1
#	$1 -> msg
# EXAMPLE:
#	bolder "This is an example" -> (in bold) "This is an example"
#=======================================================================
function bolder() {
	local msg="$1"
	echo -e "${bold}$msg${reset}"
}
