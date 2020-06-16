#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		poweroff_virtual_machine
# DESCRIPTION: 	Turns off a virtual machine
# PARAMS: 		0
#==========================================================================
# Fetch VMs
get_virtual_machines || return 1

# Keep track of runnning VMs
for vm in "${!guests[@]}"; do
	! { ps ax -o command | grep -v grep | grep -q "$vm"; } && unset_guest_value "$vm"
done
# Check running vms
((${#guests[@]} == 0)) && {
	display_info --warning "All VMs are off" 2>&1
	return 1
}

# Choose the vm to shutdown
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to poweroff simultaneously): ")

for v in "${vm[@]}"; do
	echo -e "${light_blue}Powering off ${light_yellow}$v${reset}..."
	(vboxmanage controlvm "$v" poweroff &) &>/dev/null
done
