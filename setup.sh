#!/bin/bash
#=============================================================
# NAME: setup.sh
# DESCRIPTION: Install vbox-cli alongside with his dependeces
#              and also installs vbox-top web app
#=============================================================
set -euo pipefail # Bash strict mode

# Check sudo permissions
[[ $(id -u) != 0 ]] && { echo "This must be run with sudo, exiting" && exit 1; }

# Install application in /opt directory
[[ -d "/opt" ]] || mkdir "/opt"

cp -rv ./src /opt/vbox-cli
cp -rv ./src/UnattendedTemplates /usr/share/virtualbox/

# Install dependencies
if grep -Eq "ubuntu|debian" /etc/os-release; then
        apt-get install -y virtualbox virtualbox-ext-pack python python3-pip fzf figlet wget
        wget -O /usr/share/figlet/starwars.flf http://www.figlet.org/fonts/starwars.flf
        pip3 install flask psutil
else
        pacman -Sy --noconfirm virtualbox virtualbox-host-modules-arch wget fzf python python-pip figlet
        wget -O /usr/share/figlet/fonts/starwars.flf http://www.figlet.org/fonts/starwars.flf
        pip install flask psutil
fi

# Create symlink in /usr/bin/ and for python
ln -svf /opt/vbox-cli/vbox-cli.sh /usr/bin/vbox-cli
ln -svf /usr/bin/python3 /usr/bin/python

# Flag as exec
chmod 755 -vR /opt/vbox-cli
