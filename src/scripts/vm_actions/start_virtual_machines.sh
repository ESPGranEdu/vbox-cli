#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		start_virtual_machine
# DESCRIPTION: 	Starts a virtual machine
# PARAMS: 		0
#==========================================================================
# Fetch VMs
get_virtual_machines || return 1

# Unset VM from array if running
for vm in "${!guests[@]}"; do
	{ ps ax -o command | grep -v grep | grep -q "$vm"; } && unset_guest_value "$vm"
done

# Check if all VMs are running
((${#guests[@]} == 0)) && {
	display_info --warning "All VMs are running" 1>&2
	return 1
}

# Start VMs
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to start simultaneously): ")
((${#vm[@]} == 0)) && exit 1 # CTRL + C pressed
read -rp "Start in Headless mode? (default no): " ans

for v in "${vm[@]}"; do
	if [[ "${ans,,}" == @(no|n|) ]]; then
		display_info --info "${light_blue}Starting ${light_yellow}$v${light_blue}${reset}"
		(vboxmanage startvm "$v" &) &>/dev/null
	else
		display_info --info "${light_blue}Starting ${light_yellow}$v ${light_blue}in headless mode${reset}"
		(vboxmanage startvm "$v" --type headless &) &>/dev/null
	fi
done
