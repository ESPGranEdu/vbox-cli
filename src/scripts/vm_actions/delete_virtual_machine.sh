#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		delete_virtual_machine
# DESCRIPTION: 	Unregisters VM and erase it from the host
# PARAMS: 		0
#==========================================================================
# Fetch VMs
get_virtual_machines || return 1

# Select and erase VM
for v in "${!guests[@]}"; do
	{ ps ax -o command | grep -v grep | grep -q "$v"; } && unset_guest_value
done
((${#guests[@]} == 0)) && {
	display_info --warning "All the VMs are running"
	return 1
}

mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to delete simultaneously): ")
((${#vm[@]} == 0)) && return 1 # CTRL + C pressed

for v in "${vm[@]}"; do
	display_info --info "${light_red}Erasing ${light_yellow}$v${reset}"
	# Unregister and unset from array
	(vboxmanage unregistervm --delete "$v" &) &>/dev/null

	# Auto installed VMs will maintain their folders with junk files
	# so we need to erase the folder to unsure it's fully cleaned
	rm -rf "${guests[$v]:?}"
	unset_guest_value "$v"
done
