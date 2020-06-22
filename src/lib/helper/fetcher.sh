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
	local detected_network_interfaces
	while read interface; do
		detected_network_interfaces+=("$interface")
	done < <(ip a | grep -E "state.+UP" | awk -F: '{print $2}')

	((${#detected_network_interfaces[@]} == 0)) &&
		{ display_info --error "There was an error fetching the network interfaces" && return 1; }

	# Sustitute the contents if they changed
	if (( ${#network_interfaces[@]} < ${#detected_network_interfaces[@]})); then
		network_interfaces=("${detected_network_interfaces[@]}")
	fi

	return 0
}

#===== FUNCTION ===========================================================
# NAME: get_nat_networks
# DESCRIPTION: Fetch all nat networks available in the host
# PARAMS: 0
# MODIFIED GLOBALS: natnets[]
# RETURNS:
#   0 -> natnets[]
#   1 -> 0 nat networks in the host
#==========================================================================
function get_nat_networks() {
	local IFS=$'\n'
	local detected_nat_nets

	while read network; do
		detected_nat_nets+=("$network")
	done < <(vboxmanage list natnets | grep "NetworkName:" | awk '{ print $2 }')

	((${#detected_nat_nets[@]} == 0)) &&
		{ display_info --error "There aren't Nat Networks in the host" && return 1; }

	# Sustitute the contents if they changed
	if (( ${#natnets[@]} < ${#detected_nat_nets[@]})); then
		natnets=("${detected_nat_nets[@]}")
	fi

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
	local machine="$1"
	get_virtual_machines 2>/dev/null || return 1 # No need to see here the errors

	# If a machine was passed, cache that machine only
	if [[ "$machine" ]]; then
		vm_dir="${guests[$machine]}"
		vm_info="${vm_dir}/${machine}_vbox-cli.info"
        vm_disk="$(find "$vm_dir" -iname "*.vdi" -or -iname "*.vmdk")"
        display_info --info "Updating \"$machine\" info"
        (vboxmanage showvminfo "$machine" && vboxmanage showmediuminfo "$vm_disk") >"$vm_info"
		return 0
	fi

	# Cache info from each VM
	for vm in "${!guests[@]}"; do
		vm_dir="${guests[$vm]}"
		vm_info="${vm_dir}/${vm}_vbox-cli.info" # Path to store the VM info
        vm_disk="$(find "$vm_dir" -iname "*.vdi" -or -iname "*.vmdk")"
		[[ -f "$vm_info" ]] && continue
		display_info --info "Caching ${light_yellow}\"$vm\"${reset}"
        (vboxmanage showvminfo "$vm" && vboxmanage showmediuminfo "$vm_disk") >"$vm_info"
	done
}
