#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		import_virtual_machine
# DESCRIPTION:  Imports a Virtual Machine
# PARAMS: 		0
#==========================================================================
# Variables
vsys_params=("--vsys 0")

# Get OVA file
read -rep "Specify the directory where do you store the OVA file: " ova_path
! [[ -d "$ova_path" ]] && { display_info --error "\"$ova_path\" doesn't exist" && return 1; }
ova_path="${ova_path}/$(find "$ova_path" -type f -iname "*.ova" -exec basename "{}" \; | fzf --prompt "Select the OVA file: ")"
((${#ova_path} == 0)) && return 1 # No OVA selected or Ctrl + C pressed

# Show VM info
vboxmanage import "$ova_path" --dry-run | grep -Eo "[0-9]+:.+"

# Ask if the user wants to change some VM properties before importing it
echo  # Add some padding
read -rp "Do you want to change the properties?(default: no): " ans
[[ "${ans,,}" == @(no|n|) ]] && {
	display_info --info "${light_blue}Importing ${light_yellow}${ova_path%*.ova}${reset}"
	vboxmanage import "$ova_path" >/dev/null
	display_info --info "${light_blue}Finished!!!${reset}"
	return 0 # Exit
}

while true; do
	echo "Properties of the $(basename "${ova_path%*.ova}"):"
	(
		echo -e "$(bolder "[ $(random_color 1) ${bold}]") VM Name: ${dimm}${vsys_params[1]#*--vmname}${reset}"
		echo -e "$(bolder "[ $(random_color 2) ${bold}]") CPU Core Count: ${dimm}${vsys_params[2]#*--cpus}${reset}"
		echo -e "$(bolder "[ $(random_color 3) ${bold}]") Shared RAM: ${dimm}${vsys_params[3]#*--memory}${reset}"
		echo -e "$(bolder "[ $(random_color 4) ${bold}]") Import machine"
	) | column -t -s ":"
	read -rp "Select a property: " ans

	case "$ans" in
		1)
			read -rp "What would be the name fot the VM: " vm_name
			vsys_params[1]="--vmname $vm_name"
			;;
		2)
			read -rp "How many cores do you want to assign ($total_cores in total)?: " cpus
			! [[ "$cpus" =~ ^[0-9]+$ ]] && { display_info --error "\"$prop\" not valid for cpu count" && continue; }
			vsys_params[2]="--cpus $cpus"
			;;
		3)
			read -rp "How many memory do you want to share ($total_mem MB in total)?: " memory
			! [[ "$memory" =~ ^[0-9]+$ ]] && { display_info --error "\"$prop\" not valid for memory amount" && continue; }
			vsys_params[3]="--memory $memory"
			;;
		4)
			# Check if the user changed something
			(( "${#vsys_params[@]}" == 0 )) && {
				read -rp "$(display_info --warning "You haven't changed anything, import it anyway?") " ans
				[[ "${ans,,}" == @(yes|y|) ]] && { vboxmanage import "$ova_path" >/dev/null && return 1; }
				continue
			}
			vboxmanage import "$ova_path" "${vsys_params[@]}" >/dev/null

	esac
done
