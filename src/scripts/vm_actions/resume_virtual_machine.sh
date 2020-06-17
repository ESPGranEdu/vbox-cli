#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		resume_virtual_machine
# DESCRIPTION: 	Resumes a virtual machine
# PARAMS: 		0
#==========================================================================
# Fetch VMs
get_virtual_machines || return 1

# Grab all the running VMs
for vm in "${guests[@]}"; do
	if { ps ax -o command | grep -v grep | grep "$vm"; }; then
		vm_state=$(vboxmanage showvminfo "$vm" | grep State | awk '{print $2}')
		[[ "$vm_state" != "paused" ]] && unset_guest_value "$vm" "${guests[@]}"
	else
		unset_guest_value "$vm" "${guests[@]}"
	fi
done

((${#guests[@]} == 0)) && {
	display_info --warning "There's no VMs paused..." 1>&2
	return 1
}
# Resume VMs
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to resume simultaneously): ")
((${#vm[@]} == 0)) && return 1 # CTRL + C pressed

for v in "${vm[@]}"; do
	echo -e "${light_blue}Resuming $vm ...${reset}"
	(vboxmanage controlvm "$v" resume &) &>/dev/null
done
