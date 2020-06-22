#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		import_virtual_machine
# DESCRIPTION:  Imports a Virtual Machine
# PARAMS: 		0
#==========================================================================
# Get OVA file
read -rep "Specify the directory where do you store the OVA file: " ova_path
! [[ -d "$ova_path" ]] && { display_info --error "\"$ova_path\" doesn't exist" && return 1; }
ova_path="${ova_path}/$(find "$ova_path" -type f -iname "*.ova" -exec basename "{}" \; | fzf --prompt "Select the OVA file: ")"
((${#ova_path} == 0)) && return 1 # No OVA selected or Ctrl + C pressed

# Show VM info
vboxmanage import "$ova_path" --dry-run | grep -Eo "[0-9]+:.+"

# Ask if the user wants to change some VM properties before importing it
echo  # Add some padding
display_info --info "${light_blue}Importing ${light_yellow}${ova_path%*.ova}${reset}"
vboxmanage import "$ova_path" >/dev/null
display_info --info "${light_blue}Finished!!!${reset}"

