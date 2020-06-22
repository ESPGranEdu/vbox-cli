#!/bin/bash
#==== VBOX-CLI ==========================================================
# FILE: 		vbox-cli.sh
# DESCRIPTION:	A VirtualBox CLI interface with extended functionalities
# AUTHOR:   	ESPGranEdu raplhwigum@gmail.com
# VERSION: 		1.0
#========================================================================
# Enabling usefull configs for bash session
shopt -s checkwinsize													# Check window size when resizing
shopt -s extglob														# Enable extended glob expansion
#set -euo pipefail														# Bash strict mode

# Global variables
export VIRTUALBOX_DIR="$HOME/VirtualBox VMs"                            # Usually VirtualBox creates a directory in the user's home folder
export FZF_DEFAULT_OPTS='--height 50% --border --reverse --multi'       # Options for fuzzy finder
export base_dir="$(dirname "$(readlink -f "$0")")"                      # Base location of the src folder
export total_mem="$(free -m | awk '/^Mem/ {printf "%0.0f", $2/1024}')" # Total memory in the system
export network_interfaces=()                                            # Array to store network interfaces
export natnets=()														# Array to store nat networks
export total_cores="$(nproc)"                                           # Number of total cores in system
declare -A guests; export guests                                        # Array to store VMs
export scripts_path=()													# Array to store scripts path
export scripts_name=()													# Array to store scripts name
export scripts_description=()											# Array to store scripts description
export scripts_folder=()												# Array to store scripts folder
unset nscripts															# Number of available scripts

# Source and export libraries
source "${base_dir}"/lib/colors/colors.sh
source "${base_dir}"/lib/helper/helper.sh
source "${base_dir}"/lib/helper/fetcher.sh

for func in $(declare -f | grep -E "(^\w+_?)+()" | sed 's/()//g'); do
	export -f "$func"
done

#======== FUNCTION =======================================================
# NAME: fetch_scritps
# DESCRIPTION: Save into diferent arrays the name, path and description
#			   of every	found in src
# GLOBALS MODIFIED:
#	scripts_path[]
#	scripts_name[]
#	scripts_description[]
# PARAMS: 0
# RETURN:
#	0 -> At least 1 script was found
#	1 -> The specified folder hasn't got scripts inside
#=========================================================================
function fetch_scripts() {
	# Variables
	local script_number=1
	local folder=$(ls -d "${base_dir}/scripts/$1/"* 2>/dev/null)
	nscripts=0

	# Check if the selected folder has scripts
	(( "${#folder}" == 0 )) && { display_info --error "\"$1\" hasn't got actions to perform !!!" && return 1; }

	# Save script name, description and path respectively
	for script in $folder; do

		scripts_path["$script_number"]="$script"
		scripts_description["$script_number"]=$(grep -m1 "DESCRIPTION:" "$script" | awk -F: '{gsub(/^[ \t\r\n]+/, "", $2); print $2}')
		scripts_name["$script_number"]="${script##*/}"

		((script_number++))
		((nscripts++))
	done

	return 0
}

#======== FUNCTION =======================================================
# NAME: menu
# DESCRIPTION: Show avaliable options to manipulate virtual machines
# PARAMS: 0
#=========================================================================
function menu() {
    # Variables
    local user_input
    local nfolder=1
	local script
	local description

	# Clear the output to dispay only the menu
	clear

	# Display header and check cache VMs info
	figlet -f starwars -c "vbox- cli"

	# Cache all VMs info
	cache_vm_info

	# List script folders
	for folder in "${base_dir}"/scripts/*; do
		folder="${folder##*/}"
		echo -e "$(bolder "[ $(random_color "$nfolder") ${bold}]") ${bold_cyan}$folder${reset}"
		scripts_folder[$nfolder]="$folder"
		((nfolder++))
	done
	echo

	# Fetch scripts from selected folder
	read -rp "Select -> " user_input
	if [[ "$user_input" -gt "$nfolder"  || ! "$user_input" =~ ^[0-9]+$ ]] 2>/dev/null; then

		if [[ "$user_input" -gt "$nfolder" || "$user_input" -eq 0 ]] 2>/dev/null; then
			display_info --error "Number ($user_input) out of range, try again..."
		else
			display_info --error "Invalid option ($user_input)"
		fi

		return 1
	else
		fetch_scripts "${scripts_folder[$user_input]}" || return 1
	fi


	# List actions
	for n in $(seq 1 $nscripts); do
		script="${scripts_name[$n]%*.sh}"
		description="${scripts_description[$n]}"
		echo -e "$(bolder "[ $(random_color "$n") ${bold}]")${bold_yellow}\t$script${reset}\t${dimm}$description${reset}"
	done | column -t -s $'\t'
	echo

	# Exec script
	read -rp "Select an action -> " user_input
	if ((user_input > nscripts)) || ! [[ "$user_input" =~ ^[0-9]+$ ]] 2>/dev/null ; then

		if [[ "$user_input" -gt "$nscripts" || "$user_input" -eq 0 ]] 2>/dev/null; then
			display_info --error "Number ($user_input) out of range, try again..."
		else
			display_info --error "Invalid option ($user_input)"
		fi

		return 1
	else
		source "${scripts_path[$user_input]}"
	fi

}


# Call the menu function to start the script
while true; do
	menu
	read -rsp "Press Enter to continue"
done

