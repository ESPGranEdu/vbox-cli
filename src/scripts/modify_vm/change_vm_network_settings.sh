#!/bin/bash
#==== CHANGE =============================================
# NAME: change_vm_network_settings
# DESCRIPTION: Change the network configuration
# PARAMS: 0
#===========================================================

# Fetch VMs
get_virtual_machines || return 1
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select a vm: ")

# TODO (ESPGranEdu): This must work with all NIC available
# Get the actual network configuration
# Show all available NICs for the VM
vm_info="${guests[$vm]}/${vm}_vbox-cli.info"

[[ -f "$vm_info" ]] && cache_vm_info

# Get NIC info from cached vm info
vm_nic_line=$(grep -Eo "^NIC\s[0-9]:.+" "$vm_info" | fzf --prompt "Select a NIC: ")

# if vm_nic_config is empty, assign the value 'disabled'
vm_nic_config=$(echo "$vm_nic_line" | grep -Eo "Attachment:\s[a-zA-Z0-9' ]*" | awk -F: '{gsub(/^[ \t\r\n]+/, "", $2); print $2}')
vm_nic_config=${vm_nic_config:-disabled}
vm_nic=$(echo "$vm_nic_line" | grep -Eo "^NIC\s[0-9]:" | awk -F: '{gsub(/\s/, "", $1); print tolower($1)}')
vm_nic_num=${vm_nic/nic/} # Remove "nic" word

# Display basic info
echo -e "${light_blue}\tNetwork configuration of ${light_yellow}${vm}'s ${light_green}${vm_nic^^}${reset}:"
read -rp "$(display_info --warning "Change the Network config of ${light_yellow}$vm_nic${reset}?(Y/n): ")" ans

if [[ "${ans,,}" == @(yes|y|) ]]; then
		nic_config=$(echo -e "disabled\nnat\nnat network\nbridged\nintnet\nhostonly\ngeneric" | fzf --prompt "Select NIC mode: ")
		display_info --info "${light_blue}Unplugging Virtual cable...${reset}"
		display_info --info "${light_blue}Setting ${light_yellow}${vm_nic^^}${light_blue} to ${light_yellow}$nic_config${reset}"
		display_info --info "${light_blue}Plugging Virtual cable...${reset}"
else
        return 0
fi
