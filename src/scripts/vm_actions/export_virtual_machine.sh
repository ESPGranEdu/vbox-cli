#!/bin/bash
#===== VM ACTION ==========================================================
# NAME: 		export_virtual_machine
# DESCRIPTION:  Exports a Virtual Machine
# PARAMS: 		0
#==========================================================================
# Variables
local ans

# Get VMs
get_virtual_machines || return
