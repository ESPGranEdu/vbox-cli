#!/bin/bash
#==== MISCELLANEOUS =========================================
# NAME: vbox-top
# DESCRIPTION: Starts/Stop the vbox-top server
#============================================================
# Detect if the Flask server it's already running (Stop the server)
server_pid=$(ps -ax -o pid,command | grep -v grep | grep vbox-top 2>/dev/null | awk '{print $1}')


if [[ "$server_pid" ]]; then
	display_info --info "Stopping vbox-top webserver"

	# The server instance runs on 2 independent processes, so we need to shut them down
	for pid in $server_pid; do
		kill -9 "$pid"
	done
else
	display_info --info "Starting vbox-top webserver"
	display_info --info "Server listening at ${bold}http://localhost:5000${reset}"
	(python "${base_dir}"/lib/vbox-top/main.py &) &>/dev/null
fi
