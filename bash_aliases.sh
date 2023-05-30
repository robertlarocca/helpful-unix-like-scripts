#!/bin/bash

# Copyright (c) 2023 Robert LaRocca http://www.laroccx.com

# Helpful Linux bash_aliases for sysadmins, developers and the forgetful.

# Script version and release
script_version='2.6.4'
script_release='stable'  # options devel, beta, release, stable
export BASH_ALIASES_VERSION="$script_version-$script_release"

# Set custom emoji prompt for Linux user accounts.
PS1_ORIG="$PS1"
set_emoji_ps1_prompt() {
	if [[ -f "$HOME/.caffeinate" ]]; then
		# Emoji when caffeinate is enabled
		PS1="☕ $PS1_ORIG"
	elif [[ $USER = 'root' ]]; then
		# Emoji for root
		PS1="🐳 $PS1_ORIG"
	elif [[ $USER = 'user1' ]]; then
		# Emoji for user1
		PS1="🦄 $PS1_ORIG"
	elif [[ $USER = 'user2' ]]; then
		# Emoji for user2
		PS1="🩻 $PS1_ORIG"
	elif [[ $USER = 'user3' ]]; then
		# Emoji for user3
		PS1="🐲 $PS1_ORIG"
	fi
}
set_emoji_ps1_prompt

# Windows Subsystem for Linux (WSL2) specific variables and aliases.
# Use the $NTUSER variable just like $USER from witin Linux.
# Use the $NTHOME variable just like $HOME from witin Linux.

# Set NTUSER to the Windows username if different from Linux username.
NTUSER="$USER"
NTHOME="/mnt/c/Users/$NTUSER"

alias wsl="/mnt/c/WINDOWS/system32/wsl.exe"
alias wslg="/mnt/c/WINDOWS/system32/wslg.exe"

# Change your Active Directory domain user password.
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
		/usr/lib/command-not-found "smbpasswd"
	fi
}

# Single command to disable or off the caffeinate script.
alias decaffeinate="caffeinate off"

# Prevent pubkey authentication with ssh and scp commands.
alias scp-passwd="scp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias sftp-passwd="sftp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias ssh-passwd="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

# Prevent conflicts with existing kubectl installs.
alias kubectl="microk8s kubectl"

# Similar to the macOS 'open' command.
alias open="$(which xdg-open)"

# Show the current logical volume management (lvm) storage.
lvms() {
	sudo pvs && echo && sudo vgs && echo && sudo lvs
}

# Display the current logical volume management (lvm) storage.
lvmdisplay() {
	sudo pvdisplay && echo && sudo vgdisplay && echo && sudo lvdisplay
}

# Display command reminder to create a lvm snapshot.
lvmsnapshot() {
	cat <<-EOF_XYZ
	Logical volume snapshots are created using the 'lvcreate' command.

	Examples:
	 lvcreate -L 25%ORIGIN --snapshot --name snapshot_1 /dev/ubuntu/root
	 lvcreate -L 16G -s -n snapshot_2 /dev/ubuntu/home

	See lvcreate(8) for additonal information.
	EOF_XYZ
}

# Generate a secure random password.
mkpw() {
	pwgen --capitalize --numerals --symbols --ambiguous 14 1
}

# Generate a secure random pre-shared key.
mkpsk() {
	head -c 64 /dev/urandom | base64
}

# Generate a secure random LUKS device secret.
mksecret() {
	head -c 512 /dev/urandom | base64
}

# Check website availability and display headers.
test-website() {
	local website_url="$1"

	if [[ -n "$website_url" ]]; then
		echo "$website_url"
		curl -ISs --connect-timeout 8 --retry 2 "$website_url"
	else
		for website_url in \
			https://www.apple.com \
			https://duckduckgo.com \
			https://www.google.com \
			https://www.laroccx.com \
			https://www.microsoft.com \
			https://www.netflix.com \
			https://www.wikipedia.org \
			https://ubuntu.com ; do
			echo "$website_url"
			curl -ISs --connect-timeout 8 --retry 2 "$website_url"
			echo
		done
	fi
}

# Test firewall ports using telnet.
test-port() {
	# The server address and service port are tested by default.
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
			test_port: unrecognized option '$*'
			Try 'test_port --port <port_number>' to check a specific port.
			EOF_XYZ
		fi
		;;
	esac
}

# Synchronize all Git repositories in the current directory.
git-sync() {
	case "$1" in
	-H | --help)
		cat <<-EOF_XYZ
		Usage: git-sync [DIR] ...
		Synchronize all the Git repositories in a directory.

		Examples:
		  git-sync
		  git-sync path/to/repos
		  git-sync /full/path/to/repos

		See git(1) and gittutorial(7) for additonal information.
		EOF_XYZ
		;;
	*)
		if [[ -z "$1" ]]; then
			local working_directory="$PWD"
		elif [[ -n "$1" ]] && [[ -d "$1" ]]; then
			local working_directory="$PWD"
			cd "$1"
		fi

		for i in $(ls -1); do
			if [[ -d "$i/.git" ]]; then
				cd "$i"
				echo "Synchronizing $(basename $i)..."
				git pull
				git fetch --all
				git push
				echo
				cd ..
			fi
		done

		cd "$working_directory"
		;;
	esac
}

# Update a forked Git repository by merging with upstream.
git-merge-upstream() {
	case "$1" in
	-H | --help)
		cat <<-EOF_XYZ
		Usage: git-merge-upstream [URL] ...
		Update a forked Git repository by merging with upstream.

		Examples:
		  git-merge-upstream git@example.com/project-repo.git
		  git-merge-upstream https://example.com/project-repo.git

		See git(1) and gittutorial(7) for additonal information.
		EOF_XYZ
		;;
	*)
		local upstream_url="$1"

		remote add upstream "$upstream_url"
		git remote --verbose
		git fetch upstream
		git checkout master
		git merge upstream/master
		git push origin master
		;;
	esac
}

# Toggle wireless network power management.
wifi-power() {
	if [[ -z "$1" ]]; then
		iwconfig wlan0
	else
		sudo iwconfig wlan0 power "$1"
	fi
}

# Ookla speedtest-cli alias to display minimal output by default.
alias speedtest="speedtest-cli --simple"

# Install the required apt packages used throughout this repository.
# Also contains extra commands like nmap for troubleshooting issues.
install-required-bash-alias-packages() {
	sudo apt update
	sudo apt --yes install \
		byobu \
		dnsutils \
		git \
		htop \
		nmap \
		pwgen \
		samba-common-bin \
		speedtest-cli \
		tasksel \
		telnet \
		whois
}

# Include bash_aliases_private if available.
if [[ -f "$HOME/.bash_aliases_private" ]]; then
	source $HOME/.bash_aliases_private
fi

# vi: syntax=sh ts=2 noexpandtab
