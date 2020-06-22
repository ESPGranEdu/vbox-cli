#!/bin/bash
#==== CHANGE =============================================
# NAME: change_vm_network_settings
# DESCRIPTION: Change the network configuration
# PARAMS: 0
#===========================================================

# Fetch VMs
get_virtual_machines || return 1
mapfile -t vm < <(printf "%s\n" "${!guests[@]}" | fzf --prompt "Select a vm: ")
(( ${#guests[@]} == 0 )) && return 1 # Ctrl + C pressed

# Show all available NICs for the VM
vm_info="${guests[$vm]}/${vm}_vbox-cli.info"

# Get NIC info from cached vm info
vm_nic_line=$(grep -Eo "^NIC\s[0-9]:.+" "$vm_info" | fzf --prompt "Select a NIC: ")

# if vm_nic_config is empty, assign the value 'disabled'
vm_nic_config=$(echo "$vm_nic_line" | grep -Eo "Attachment:\s[a-zA-Z0-9'_ ]*" | awk -F: '{gsub(/^[ \t\r\n]+/, "", $2); print $2}')
vm_nic_config=${vm_nic_config:-disabled}
vm_nic=$(echo "$vm_nic_line" | grep -Eo "^NIC\s[0-9]:" | awk -F: '{print tolower($1)}' | tr -d " ")
vm_nic_num=${vm_nic/nic/} # Remove "nic" word
if ps ax -o command | grep -v grep | grep -q "$vm"; then
	vboxmanage_command="controlvm"
else
	vboxmanage_command="modifyvm"
fi

# Display basic info
echo -e "${light_blue}Network configuration of ${light_yellow}${vm}'s ${light_green}${vm_nic^^}${reset}:"
echo -e "${light_blue}Actual NIC config: ${light_yellow}$vm_nic_config${reset}"
read -rp "$(display_info --warning "Change the Network config of ${light_yellow}$vm_nic${reset}?(Y/n): ")" ans

if [[ "${ans,,}" == @(yes|y|) ]]; then

	[[ "$vm_nic_config" == "disabled" && "$vboxmanage_command" == "controlvm" ]] &&
        { display_info --warning "In order to activate a NIC, the VM must be switched off" && return 1;}

	# Check if the VM is running, if it is use "controlvm" instead of "modifyvm"
	nic_config=$(echo -e "none\nnat\nnat network\nbridged\nintnet\nhostonly\ngeneric" | fzf --prompt "Select NIC mode: ")
	display_info --info "${light_blue}Setting ${light_yellow}${vm_nic^^}${light_blue} to ${light_yellow}$nic_config${reset}"
	case "$nic_config" in
		"none")
			if [[ "$vboxmanage_command" == "modifyvm" ]]; then
				vboxmanage "$vm" --"$vm_nic" "${nic_config//\ /}"
			else
				display_info --info "${light_blue}Unpluging virtual cable${reset}"
				vboxmanage "$vboxmanage_command" "$vm" "setlinkstate$vm_nic_num" off

				vboxmanage "$vm" "$vm_nic" "null"

				display_info --info "${light_blue}Plugging virtual cable${reset}"
				vboxmanage "$vm" "setlinkstate$vm_nic_num" on
			fi
			;;

		"nat network")
			# Select the disired nat network
			get_nat_networks || return 1
			mapfile -t net < <(printf "%s\n" "${natnets[@]}" | fzf --prompt "Select the nat network: ")
			(( ${#net[@]} == 0 )) && return 1 # Ctrl + C pressed

			if [[ "$vboxmanage_command" == "modifyvm" ]]; then
				vboxmanage "$vboxmanage_command" "$vm" --"$vm_nic" "${nic_config//\ /}" #&>/dev/null
				vboxmanage "$vboxmanage_command" "$vm" --nat-network"$vm_nic_num" "$net"
			else
				display_info --info "${light_blue}Unpluging virtual cable${reset}"
				vboxmanage "$vboxmanage_command" "$vm" "setlinkstate$vm_nic_num" off

				# Actually set the new config
				vboxmanage "$vboxmanage_command" "$vm" "$vm_nic" "${nic_config//\ /}" "$net" #&>/dev/null

				display_info --info "${light_blue}Pluging virtual cable${reset}"
				vboxmanage "$vboxmanage_command" "$vm" "setlinkstate$vm_nic_num" on
			fi
			;;

		"bridged")
			# Select the network interface
			get_network_interfaces || return 1
			mapfile -t net_if < <(printf "%s\n" "${network_interfaces[@]}" | fzf --prompt "Select the network interface to bridge: ")
			(( ${#net_if[@]} == 0 )) && return 1 # Ctrl + C pressed

			if [[ "$vboxmanage_command" == "modifyvm" ]]; then
				vboxmanage "$vboxmanage_command" "$vm" --"$vm_nic" "${nic_config//\ /}" #&>/dev/null
				vboxmanage "$vboxmanage_command" "$vm" --bridgeadapter"$vm_nic_num" "$net_if"
			else
				display_info --info "${light_blue}Unpluging virtual cable${reset}"
				vboxmanage "$vboxmanage_command" "$vm" "$vm_nic" "${nic_config//\ /}" "$net_if" #&>/dev/null
				display_info --info "${light_blue}Pluging virtual cable${reset}"
			fi
			;;
		*)
			if [[ "$vboxmanage_command" == "modifyvm" ]]; then
				vboxmanage "$vboxmanage_command" "$vm" --"$vm_nic" "${nic_config//\ /}" #&>/dev/null
			else
				display_info --info "${light_blue}Unpluging virtual cable${reset}"
				vboxmanage "$vboxmanage_command" "$vm" "setlinkstate$vm_nic_num" off

				# Actually set the new config
				vboxmanage "$vboxmanage_command" "$vm" "$vm_nic" "${nic_config//\ /}" #&>/dev/null

				display_info --info "${light_blue}Pluging virtual cable${reset}"
				vboxmanage "$vboxmanage_command" "$vm" "setlinkstate$vm_nic_num" on
			fi
			;;
	esac
	# Update VM info
	cache_vm_info "$vm"
else
        return 1
fi
