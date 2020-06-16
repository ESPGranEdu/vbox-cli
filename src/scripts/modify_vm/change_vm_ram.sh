#!/bin/bash
#==== FUNCTION =============================================
# NAME: change_vm_ram
# DESCRIPTION: Change the amount of dedicated RAM
# PARAMS: 0
#===========================================================
# Fetch VMs
get_virtual_machines
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select a vm: ")

# Check if the VM is running
ps ax -o command | grep -v grep | grep -q "$vm" && {
	display_info --warning "${light_blue}$vm${reset} is actually running...\nPlease shutdown the VM in order to change the shared RAM" 1>&2
	return
}

# Change VM ram
actual_vm_shared_ram=$(vboxmanage showvminfo "$vm" | grep "Memory size" | awk '{print $3}' | tr -d " " )
read -rp "Specify the amount of RAM (actual: $actual_vm_shared_ram): " memory
while ((memory <= 0 || memory > total_mem*1024)); do
	display_info --error "Specified amount (${memory}MB) is higher than host memory (${total_mem}GB)"
	read -rp "Specify the amount of RAM (actual: $actual_vm_shared_ram): " memory
done

echo -e "${light_blue}Changing ${light_yellow}$actual_vm_shared_ram${reset} ${light_blue}to ${light_yellow}${memory}MB${reset} ${light_blue}for ${light_cyan}$vm${reset}"
vboxmanage modifyvm "$vm" --memory "$memory"
