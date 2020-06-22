#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		export_virtual_machine
# DESCRIPTION:  Exports a Virtual Machine
# PARAMS: 		0
#==========================================================================
# Variables
exported_vms=0

# Get VMs
get_virtual_machines || return 1

# Unset VM from array if running
for vm in "${!guests[@]}"; do
	{ ps ax -o command | grep -v grep | grep -q "$vm"; } && unset_guest_value "$vm"
done

((${#guests[@]} == 0)) && {
	display_info --warning "All VMs are running" 1>&2
	return 1
}

# Export VMs
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select the VMs (use TAB to choose VMs to export): ")
((${#vm[@]} == 0)) && return 1 # Ctrl + C pressed

read -rep "Choose the destination to store the .ova files: " dest_path
for v in "${vm[@]}"; do
    ova_path="${dest_path}/$v.ova"
    (vboxmanage export "$v" -o "$ova_path" &>/dev/null) &

	fancy_waiter "$(get_pid vboxmanage)" \
		"$(display_info --info "${light_blue}Exporting ${light_yellow}$v${reset}")" \
		"$(display_info --error "Something went wrong exporting ${light_yellow}$v${reset}")"

    (($? == 0)) && ((exported_vms++))
done

if (( exported_vms != ${#vm[@]} )); then
    display_info --error "${light_yellow}$(( ${#vm[@]} - exported_vms ))${light_blue} failed to export${reset}"
fi

display_info --info "${light_yellow}$exported_vms${light_blue} VM/s exported${reset}"
