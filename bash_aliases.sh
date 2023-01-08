#!/bin/bash

# Copyright (c) 2023 Robert LaRocca http://www.laroccx.com

# Helpful Linux bash_aliases for sysadmins, developers and the forgetful.

export BASH_ALIASES_VERSION="2.4.15-$HOSTNAME"

# Set custom PS1 prompt for localhost.
PS1_ORIG="$PS1"
set_emoji_ps1_prompt() {
	if [[ -f "$HOME/.caffeinate" ]]; then
		PS1="☕ $PS1_ORIG"
	elif [[ $USER = 'root' ]]; then
		PS1="🧀 $PS1_ORIG"
	elif [[ $USER = 'user1' ]]; then
		PS1="👽 $PS1_ORIG"
	elif [[ $USER = 'user2' ]]; then
		PS1="🐉 $PS1_ORIG"
	fi
}
set_emoji_ps1_prompt

# Edit bash aliases using gedit (Text Editor).
edit_aliaess() {
	case "$1" in
	code)
		# Visual Studio Code
		code $HOME/.bash_aliases
		;;
	gedit)
		# gedit Text Editor
		gedit $HOME/.bash_aliases
		;;
	nano)
		nano $HOME/.bash_aliases
		;;
	subl)
		# Sublime Text
		subl $HOME/.bash_aliases
		;;
	vi | vim)
		vim $HOME/.bash_aliases
		;;
	*)
		# Use the configured default GNOME text editor
		$(which xdg-open) $HOME/.bash_aliases
		;;
	esac
}

# Windows Subsystem for Linux (WSL2) specific variables and aliases
# Set to the Windows username if different from the Linux username
# Use the $NTUSER variable just like $USER witin Linux
NTUSER="$USER"
# Use the $USERS variable just Like $HOME witin Linux
USERS="/mnt/c/Users/$NTUSER"

# Change Active Directory password on domain controller.
adpasswd() {
	# Set to the Active Directory username if different from the Linux username.
	local domain_user="$USER"

	# Set the realm and domain name.
	local domain_realm="EXAMPLE"
	local domain_name="example.com"

	# Set the default domain controller IP address.
	# May also use $domain_name to use any avaiable domain controller.
	local domain_controller="192.168.1.2"

	# The 'samba-common-bin' packaged must be installed.
	if [[ -x "$(which smbpasswd)" ]];then
		smbpasswd -U "$domain_realm"/"$domain_user" -r "$domain_controller"
	else
		echo "Command 'smbpasswd' not found, but can be installed with:"
		echo "sudo apt install samba-common-bin"
	fi
}

# Single command to disable the 'caffeinate' script.
alias decaffeinate="caffeinate off"

# Prevent conflicts with existing kubectl installs
alias kubectl="microk8s kubectl"

# Similar to the macOS 'open' command
alias open="$(which xdg-open)"

# Show the current logical volume management (lvm) storage
lvms() {
	sudo pvs && echo && sudo vgs && echo && sudo lvs
}

# Display the current logical volume management (lvm) storage
lvmdisplay() {
	sudo pvdisplay && echo && sudo vgdisplay && echo && sudo lvdisplay
}

# Display command reminder to create a lvm snapshot
lvmsnapshot() {
	cat <<-EOF_XYZ
	Logical volume snapshots are created using the 'lvcreate' command.

	Examples:
	 lvcreate -L 25%ORIGIN --snapshot --name snapshot_1 /dev/ubuntu/root
	 lvcreate -L 16G -s -n snapshot_2 /dev/ubuntu/home

	See lvcreate(8) for additonal information.
	EOF_XYZ
}

# Generate a secure random password
mkpw() {
	pwgen --capitalize --numerals --symbols --ambiguous 14 1
}

# Generate a secure random pre-shared key
mkpsk() {
	head -c 50 /dev/urandom | base64
}

# Check website availability and display headers
test_website() {
	local server_address="$1"

	if [[ -n "$server_address" ]]; then
		echo "$server_address"
		curl -ISs --connect-timeout 8 --retry 2 "$server_address"
	else
		for server_address in \
			https://www.apple.com \
			https://duckduckgo.com \
			https://www.google.com \
			https://www.microsoft.com \
			https://www.netflix.com \
			https://www.wikipedia.org \
			https://ubuntu.com ; do
			echo "$server_address"
			curl -ISs --connect-timeout 8 --retry 2 "$server_address"
			echo
		done
	fi
}e

# Test firewall ports using telnet
test_port() {
	local server_address='telnet.example.com'
	local service_port='8738'

	case "$1" in
	--port | -p)
		telnet $server_address "$2"
		;;
	*)
		if [[ -z "$1" ]]; then
			telnet $server_address $service_port
		else
			cat <<-EOF_XYZ
			test_port: unrecognized option '$1'
			Try 'test_port --port <number>' to check a specific port.
			EOF_XYZ
		fi
		;;
	esac
}

# Merge current master with upstream
git_merge_upstream() {
	case "$1" in
	-H | --help)
		cat <<-EOF_XYZ
		Usage: git_merge_upstream [URL]...
		Update a forked Git repository by merging with upstream.

		Examples:
		 remote add upstream https://example.com/project-repo.git
		 git remote -v
		 git fetch upstream
		 git checkout master
		 git merge upstream/master
		 git push origin master

		See git(1) and gittutorial(7) for additonal information.
		EOF_XYZ
		;;
	*)
		local upstream_repo_address="$1"

		remote add upstream $upstream_repo_address
		git remote -v
		git fetch upstream
		git checkout master
		git merge upstream/master
		git push origin master
		;;
	esac
}

# Toggle wireless network power management
wifi_power() {
	if [[ -z "$1" ]]; then
		iwconfig wlan0
	else
		sudo iwconfig wlan0 power "$1"
	fi
}

# Ookla speedtest-cli alias to display minimal output
alias speedtest="speedtest-cli --simple"

# Include bash_aliases_private
if [[ -f "$HOME/.bash_aliases_private" ]]; then
	source $HOME/.bash_aliases_private
fi

# vi: syntax=sh ts=2 noexpandtab
