#!/bin/bash
#==== FUNCTION =============================================
# NAME: change_cpu_cores
# DESCRIPTION: Change the number of physical cores
# PARAMS: 0
#===========================================================
# Fetch VMs
get_virtual_machines || return 1
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select a vm: ")

# Check if the VM is running
ps ax -o command | grep -v grep | grep -q "$vm" && {
	display_info --warning "${light_blue}$vm${reset} is actually running...\nPlease shutdown the VM in order to change the CPU cores" 1>&2
	return
}

#Change CPU cores
vm_info="${guests[$vm]}/${vm}_vbox-cli.info"
actual_vm_cpu_cores=$(grep "Number of CPUs:" "$vm_info" | awk -F: '{print $2}' | tr -d " ")
read -rp "How many cores do you want to assing (actual core count: $actual_vm_cpu_cores): " cpu_cores
while ((cpu_cores == 0 || cpu_cores > total_cores)); do
	display_info --error "Specified amount ($cpu_cores) is higher than host core count ($total_cores)" 1>&2
	read -rp "How many cores do you want to assing (actual: $actual_vm_cpu_cores): " cpu_cores
done

display_info --info "${light_blue}Changing ${light_yellow}$actual_vm_cpu_cores${reset} ${light_blue}cores to ${light_yellow}$cpu_cores${reset} ${light_blue}for ${light_cyan}$vm${reset}"
vboxmanage modifyvm "$vm" --cpus "$cpu_cores"

# Update the cached info
cache_vm_info "$vm"
