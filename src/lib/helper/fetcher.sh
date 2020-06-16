#!/bin/bash
# shellcheck disable=SC2155
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2154
# shellcheck disable=SC2128
# shellcheck disable=SC2034
# shellcheck disable=SC2207

#===== FUNCTION ===========================================================
# NAME: get_virtual_machines
# DESCRIPTION: Fetch all the virtual machines avaliable on the host
# PARAMS: 0
# MODIFIED GLOBALS: guests[]
# RETURNS:
#   0 -> guests[]
#   1 -> No VM found in VIRTUALBOX_DIR
#==========================================================================
function get_virtual_machines() {
	# Store into and array
	local IFS=$'\n'
	for vm_dir in $(find -L "$VIRTUALBOX_DIR" -type f -iname "*.vbox"); do
		vm_dir="${vm_dir%/*}"
		vm_name="${vm_dir##*/}"
		guests["$vm_name"]="$vm_dir"
	done

	((${#guests[@]} == 0)) && { display_info --error "No VMs found on host machine" && return 1; }
	return 0
}

#===== FUNCTION ===========================================================
# NAME: get_network_interfaces
# DESCRIPTION: Fetch all network interfaces available on the host
# PARAMS: 0
# MODIFIED GLOBALS: network_interfaces[]
# RETURNS:
#   0 -> network_interfaces[]
#   1 -> All network interfaces are DOWN
#==========================================================================
function get_network_interfaces() {
        local IFS=$'\n'
        mapfile -t network_interfaces < <(ip a | grep -E "state.+UP" | awk -F: '{print $2}')

        ((${#network_interfaces[@]} == 0)) &&
			{ display_info --error "There was an error fetching the network interfaces" && return 1; }
        return 0
}

#==== FUNCTION ==========================================================
# NAME: cache_vm_info
# DESCRIPTION: Cache the specs of all VMs
# PARAMS: 0
# EXAMPLE:
#	cache_vm_info -> [ INFO ] Caching "VM" specs into ...
#========================================================================
function cache_vm_info() {
	local IFS=$'\n'
	get_virtual_machines || return 1

	# Cache info from each VM
	for vm in "${!guests[@]}"; do
		vm_dir="${guests[$vm]}"
		vm_info="${vm_dir}/${vm}_vbox-cli.info" # Path to store the VM info
        vm_disk="$(find "$vm_dir" -iname "*.vdi" -or -iname "*.vmdk")"
		[[ -f "$vm_info" ]] && continue
		display_info --info "Caching ${light_yellow}\"$vm\"${reset} info into ${light_green}\"$vm_info\"${reset}"
        (vboxmanage showvminfo "$vm" && vboxmanage showmediuminfo "$vm_disk") >"$vm_info"
	done
}
