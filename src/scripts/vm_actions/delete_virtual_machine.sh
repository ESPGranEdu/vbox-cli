#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		delete_virtual_machine
# DESCRIPTION: 	Unregisters VM and erase it from the host
# PARAMS: 		0
#==========================================================================
# Fetch VMs
get_virtual_machines || exit 1

# Select and erase VM
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to delete simultaneously): ")
((${#vm[@]} == 0)) && exit 1 # CTRL + C pressed

for v in "${vm[@]}"; do
	echo -e "${light_red}Erasing $v...${reset}"
	# Unregister and unset from array
	(vboxmanage unregistervm --delete "$v" &) &>/dev/null
	unset_guest_value "$v"

	# Auto installed VMs will maintain their folders with junk files
	# so we need to erase the folder to unsure it's fully cleaned
	rm -rf "${guests[$v]}:?"
done
