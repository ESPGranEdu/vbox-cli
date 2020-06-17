#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		pause_virtual_machine
# DESCRIPTION: 	Pauses a virtual machine
# PARAMS: 		0
#==========================================================================
# Fetch VMs
get_virtual_machines || return 1

# Grab all the running VMs
echo -en "\e[KScanning..."
for vm in "${guests[@]}"; do
	if { ps ax -o command | grep -v grep | grep -q "$vm"; }; then
		vm_state=$(vboxmanage showvminfo "$vm" | grep State | awk '{print $2}')
		[[ "$vm_state" == "paused" ]] && unset_guest_value "$vm" "${guests[@]}"
	else
		unset_guest_value "$vm" "${guests[@]}"
	fi
done

# Check if there's no running VM
((${#guests[@]} > 0)) || {
	display_info --warning "All VMs are paused..." 1>&2
	return 1
}

# Pause VMs
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to pause simultaneously): ")
((${#vm[@]} == 0)) && return 1 # CTRL + C pressed

for v in "${vm[@]}"; do
	echo -e "${light_blue}Pausing $v ...${reset}"
	(vboxmanage controlvm "$v" pause &) &>/dev/null
done
