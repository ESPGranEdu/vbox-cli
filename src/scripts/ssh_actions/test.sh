#!/bin/bash
#==== SSH ACTION =============================================
# NAME: test
# DESCRIPTION: This is only a test
# PARAMS: 0
#=============================================================
for i in {16..21} {21..16} ; do
	echo -en "\e[48;5;${i}m \e[0m"
done
echo

