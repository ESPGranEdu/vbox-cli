#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		create_virtual_machine
# DESCRIPTION: 	Creates a virtual machine
# PARAMS: 		0
#==========================================================================

((oc++))
read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Insert VM name: " vm_name
while ! [[ "$vm_name" ]]; do
	display_info --error "VM name empty"
	read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Insert VM name: " vm_name
done
# Check if the VM that the users tries to create it's already created
[[ -d "$VIRTUALBOX_DIR/$vm_name" ]] && {
	display_info --warning "$vm_name it's already created!"
	echo -e "${light_blue}VM name will be ${light_yellow}$vm_name (1)${reset}"
	vm_name="$vm_name (1)"
}

# Set VM type
((oc++))
os_type=$(vboxmanage list ostypes | grep "^ID:" | fzf --prompt "What type of OS it will be?: " | awk '{print $2}')
while ! [[ "$os_type" ]]; do
	display_info --error "OS type was not selected"
	os_type=$(vboxmanage list ostypes | grep "^ID:" | fzf --prompt "What type of OS it will be?: " | awk '{print $2}')
done

echo "$(bolder "[ $(random_color "$oc") ${bold}]") What type of OS it will be?: $os_type"

# Set the memory, CPU cores, VRAM for the VM and check if the user input is valid
((oc++))
read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Set the memory (in MB): $(printf "%.*f" 0 "$total_mem") GB / " memory
while ((memory > (total_mem*1024) || memory <= 0)); do
	(( memory > (total_mem*1024) )) && display_info --error "Memory value ($memory) higher than host memory!"
	(( memory <= 0 )) && display_info --error "Invalid memory value"
	read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Set the memory (in MB): $(printf "%.*f" 0 "$total_mem") GB / " memory
done

((oc++))
read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") How many cores do you want to share? ($total_cores cores available): " cpu_cores
while (( cpu_cores > total_cores || cpu_cores <= 0)); do
	(( cpu_cores > total_cores )) && display_info --error "Core count ($cpu_cores) higher than host core count"
	(( cpu_cores <= 0 )) && display_info --error "Invalid core count"
	read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") How many cores do you want to share? ($total_cores cores available): " cpu_cores
done

((oc++))
read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") How many VRAM do you want to share with the VM (8 MB min / 128 MB max): " vram
while (( vram < 8 || vram > 128 )); do
	display_info --error "VRAM value ($vram) too low or too high!"
	read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") How many VRAM do you want to share with the VM (8 MB min / 128 MB max): " vram
done

# Set storage for the VM
((oc++))
read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Set the storage for the VM (in GB): " storage
while ((storage <= 0)); do
	display_info --error "Invalid amount"
	read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Set the storage for the VM (in GB): " storage
done

# Set the ISO image
((oc++))
read -rp "$(bolder "[ $(random_color "$oc") ${bold}]") Do you want to insert a OS's ISO image for the VM? (default yes): " sel

[[ "${sel,,}" == @(yes|y|"") ]] && {
	read -rep "Specify the directory where do you store ISO image/s: " iso_path
	iso_count=$(find "$iso_path" -type f -iname "*.iso" 2>/dev/null | wc -l)

	while [[ ! -d "$iso_path" || $iso_count -eq 0 ]]; do
		if ! [[ -d "$iso_path" ]]; then
			display_info --error "Invalid path"
		elif ((iso_count == 0)); then
			display_info --error "No ISO image/s found"
		fi

		read -rep "Specify another directory where do you store ISO image/s: " iso_path
		iso_count=$(find "$iso_path" -type f -iname "*.iso" | wc -l)
	done

	iso_path="${iso_path}/$(find "$iso_path" -type f -iname "*.iso" -exec basename "{}" \; | fzf --prompt "Select the ISO image: ")"

	while ! [[ -f "$iso_path" ]]; do
		display_info --error "ISO image not selected"
		iso_path="${iso_path}/$(find "$iso_path" -type f -iname "*.iso" -exec basename "{}" \; | fzf --prompt "Select the ISO image: ")"
	done

	echo "Select the ISO image: $iso_image"
}


# Configure the VM with the specified options and display info
echo -e "${light_blue}Creating ${green}$vm_name:${reset}"
vboxmanage createvm --name "$vm_name" --ostype "$os_type" --register &>/dev/null

# Creating storage
echo -e "\t${light_blue}-> Setting ${light_yellow}$storage GB ${light_blue}for VM storage${reset}"
vboxmanage createmedium disk --filename "$VIRTUALBOX_DIR/$vm_name/$vm_name.vdi" --size $((storage * 1024)) --format VDI &>/dev/null
vboxmanage storagectl "$vm_name" --name "SATA Controller" --add sata --controller "IntelAhci" &>/dev/null
vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VIRTUALBOX_DIR/$vm_name/$vm_name.vdi" &>/dev/null
vboxmanage storagectl "$vm_name" --name "IDE Controller" --add ide --controller PIIX4
! [[ "$iso_path" ]] ||
	vboxmanage storageattach "$vm_name" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${iso_path}"

# Enabling useful options that are disabled by default
echo -e "\t${light_blue}-> Setting ${light_red}KVM${reset} ${light_blue}paravirtualization to increase VM performance${reset}"
vboxmanage modifyvm "$vm_name" --paravirtprovider kvm

((cpu_cores > 1)) && {
	echo -e "\t${light_blue}-> Enabling ${light_yellow}x2APIC${reset} ${light_blue}support to enhance VM performance with ${light_yellow}$cpu_cores${reset} ${light_blue}cores${reset}"
	vboxmanage modifyvm "$vm_name" --x2apic on
}

# Setting vCPUs
echo -e "\t${light_blue}-> Sharing ${light_yellow}$cpu_cores${light_blue} cores${reset}"
vboxmanage modifyvm "$vm_name" --cpus "$cpu_cores" &>/dev/null

# Sharing RAM
echo -e "\t${light_blue}-> Sharing ${light_yellow}$memory MB ${light_blue}of RAM${reset}"
vboxmanage modifyvm "$vm_name" --memory "$memory" &>/dev/null

# Sharing VRAM
echo -e "\t${light_blue}-> Sharing ${light_yellow}$vram MB ${light_blue}of VRAM${reset}"
vboxmanage modifyvm "$vm_name" --vram "$vram" &>/dev/null

# Ask the user if he wants to turn on the VM
read -rp "Do you want to start the VM? (yes/no): " sel
[[ "${sel,,}" == @(yes|y|"") ]] && {
	echo -e "${light_blue}Starting $vm_name...${reset}"
	vboxmanage startvm "$vm_name" &>/dev/null
}


