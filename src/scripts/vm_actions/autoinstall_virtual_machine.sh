#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		autoinstall_virtual_machine
# DESCRIPTION:	Auto install a virtual machine based on a Template file
#				(Templates located at "/usr/share/virtualbox/UnattendedTemplates")
# PARAMS: 		0
#==========================================================================
# Variables
local iso_path

# Always set the OS type to 64 bits
os_type="$(echo -e "Windows10\nUbuntu" | fzf --prompt "Select the OS: ")_64"

read -rp "$(bolder "[ $(random_color "1") ${bold}]") What it would be the name of this VM?: " vm_name
read -rep "Specify the directory where do you store the ISO image: " iso_path
echo "Select the ISO image: $iso_image"
iso_path="${iso_path}/$(find "$iso_path" -type f -iname "*.iso" -exec basename "{}" \; | fzf --prompt "Select the ISO image: ")"

# Display specs of the VM
echo -e "${light_blue}Creating $vm_name:${reset}"
vboxmanage createvm --name "$vm_name" --ostype "$os_type" --register &>/dev/null
echo -e "\t${light_blue}-> Setting 20 GB for VM storage${reset}"
vboxmanage createmedium disk --filename "$VIRTUALBOX_DIR/$vm_name/$vm_name.vdi" --size $((20 * 1024)) --format VDI &>/dev/null
vboxmanage storagectl "$vm_name" --name "SATA Controller" --add sata --controller "IntelAhci" &>/dev/null
vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VIRTUALBOX_DIR/$vm_name/$vm_name.vdi" &>/dev/null
vboxmanage storagectl "$vm_name" --name "IDE Controller" --add ide --controller PIIX4 &>/dev/null
vboxmanage storageattach "$vm_name" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$iso_path" &>/dev/null
echo -e "\t${light_blue}-> Enabling x2APIC support to enhance VM performance with 2 cores"
vboxmanage modifyvm "$vm_name" --x2apic on
echo -e "\t${light_blue}-> Setting KVM paravirtualization to increase VM performance"
vboxmanage modifyvm "$vm_name" --paravirtprovider kvm
echo -e "\t${light_blue}-> Sharing ${light_yellow}2 ${light_blue}cores${reset}"
vboxmanage modifyvm "$vm_name" --cpus 2 &>/dev/null
echo -e "\t${light_blue}-> Sharing ${light_yellow}2048 MB ${light_blue}of RAM${reset}"
vboxmanage modifyvm "$vm_name" --memory "2048" &>/dev/null
echo -e "\t${light_blue}-> Sharing ${light_yellow}64 MB ${light_blue}of VRAM${reset}"
vboxmanage modifyvm "$vm_name" --vram "64" &>/dev/null

# Configure the unattended install
vboxmanage unattended install "$vm_name" --user=vbox \
	--password=vbox \
	--iso="$iso_path" \
	--install-additions \
	--locale=es_ES \
	--country=ES \
	--time-zone=UTC \
	--language=es-ES &>/dev/null

read -rp "Do you want to start $vm_name? (default yes): " sel
[[ "${sel,,}" == @(yes|y|"") ]] && {
	echo -e "${light_blue}Starting $vm_name...${reset}"
	vboxmanage startvm "$vm_name" &>/dev/null
}
echo -e "User credentials:\n${light_yellow}Username:${reset}vbox\n${light_yellow}Password:${reset}vbox"
