#!/bin/bash

# Copyright (c) 2024 Robert LaRocca http://www.laroccx.com

# Helpful Linux bash_aliases for sysadmins, developers and the forgetful.

# Script version and release
script_version='2.9.1'
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
		PS1="🧀 $PS1_ORIG"
	elif [[ $USER = 'user1' ]]; then
		# Emoji for user1
		PS1="🦄 $PS1_ORIG"
	elif [[ $USER = 'user2' ]]; then
		# Emoji for user2
		PS1="🩻 $PS1_ORIG"
	elif [[ $USER = 'user3' ]]; then
		# Emoji for user3
		PS1="🧟 $PS1_ORIG"
	fi
}
set_emoji_ps1_prompt

# User options for bash_aliases to show aliases, commands, help and version.
bash_aliases() {
	show_help_message() {
		cat <<-EOF_XYZ
		Usage: bash_aliases | alias | command [OPTION] [PARAMETER]...
		Helpful Linux bash_aliases for sysadmins, developers and the forgetful.

		This bash_aliases script by default (without an option) will only return
		the text 'OK'. The commands section displays aliases and functions that
		may be executed without the bash_aliases prefix, just like any other
		installed Linux program or builtin tools and utilities.

		Aliases:
		kubectl - alias to prevent microk8s conflicts with existing (kubectl) packages

		scp-passwd -  alias to prevent secure copy (scp) pubkey authentication
		sftp-passwd - alias to prevent secure file transfer (sftp) pubkey authentication
		ssh-passwd - alias to prevent secure remote login (ssh) pubkey authentication

		speedtest - alias for Ookla (speedtest-cli) command with minimal output

		wsl - alias for Windows PowerShell (wsl.exe) command
		wslg - alias for Windows PowerShell (wslg.exe) command

		Commands:
		adpasswd - change your Active Directory domain user password

		caffeinate - prevent the system suspend and hibernation timer (keep awake)
		decaffeinate - restore the default suspend and hibernation timer (allow sleep)

		open - open or edit file using the default GNOME application

		lvmdisplay - show the logical volume management storage details
		lvms - show the logical volume management storage
		lvmsnapshot - show example commands how to create lvm snapshots

		mkpsk - generate a secure random 64 character pre-shared key
		mkpw - generate a secure ambiguous random 14 character password
		mksecret - generate a secure random 512 character LUKS secret

		test-port - check network port and try to connect with telnet
		test-website - check website availability and display headers

		wifi-power - toggle wireless network power management

		Options:
		version - show version information
		help - show this help message

		Exit Status:
		0 - ok
		1 - minor issue
		2 - serious error

		Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/helpful-linux-bash-scripts

		See bash(1) dash(1) man(1) nologin(8) apt(8) and os-release(5) for additional
		information and to provide insight how this script works.
		EOF_XYZ
	}

	show_version_information() {
		cat <<-EOF_XYZ
		bash_aliases $script_version-$script_release
		Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/helpful-linux-bash-scripts
		EOF_XYZ
	}

	error_unrecognized_option() {
		cat <<-EOF_XYZ
		bash_aliases: unrecognized option '$2'
		Try 'swupdate --help' for more information.
		EOF_XYZ
	}

	case "$2" in
	--help | help)
		show_help_message
		;;
	--version | version)
		show_version_information
		;;
	*)
		# Default
		if [[ -z "$2" ]]; then
			echo "OK"
			exit 0
		else
			error_unrecognized_option "$*"
			exit 1
		fi
		;;
	esac
}

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
	# Use the current username when specific username not provided.
	if [[ -z "$1" ]]; then
		# Set to the Active Directory username if different
		# from the Linux username variable.
		local domain_user="$USER"
	else
		# Use the specific username provided.
		local domain_user="$1"
	fi

	# Set the realm and domain name.
	local domain_realm="EXAMPLE"
	local domain_name="example.com"

	# Set the default domain controller IPv4 address or FQDN.
	# NOTE: May also use the $domain_name variable for best available domain controller.
	# local domain_controller="192.168.99.21"
	local domain_controller="$domain_name"

	# The 'samba-common-bin' packaged must be installed.
	if [[ -x "$(which smbpasswd)" ]]; then
		smbpasswd -U "$domain_realm"/"$domain_user" -r "$domain_controller"

		# Display reminder after changed password.
		smbpasswd_status="$?"
		if [[ "$smbpasswd_status" == 0 ]]; then
			echo "Reminder: Lock workstation to begin using changed password" 2>&1
		fi
	else
		/usr/lib/command-not-found "smbpasswd"
	fi
}

# Clear the current shell history after executing clean command.
alias clean="$(which clean) $* && history -c"

# Single command to disable or off the caffeinate script.
alias decaffeinate="caffeinate off"

# Prevent conflicts with existing kubectl installs.
alias kubectl="microk8s kubectl"

# Similar to the macOS 'open' command.
alias open="$(which xdg-open)"

# Prevent pubkey authentication with OpenSSH related commands.
alias scp-passwd="scp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias sftp-passwd="sftp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias ssh-passwd="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

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

	See lvcreate(8) for additional information.
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

# Toggle wireless network power management.
wifi-power() {
	# The wireless network interface name.
	local wifi_iface="wlp2s0"

	if [[ -z "$1" ]]; then
		iwconfig "$wifi_iface"
	else
		sudo iwconfig "$wifi_iface" power "$1"
	fi
}

# Ookla speedtest-cli alias to display minimal output by default.
alias speedtest="speedtest-cli --simple"

# Install the required apt packages used throughout this repository.
# Also contains extra commands like nmap for troubleshooting issues.
install-helpful-linux-bash-scripts-packages() {
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

# Include bash_private if available.
if [[ -f "$HOME/.bash_private" ]]; then
	source $HOME/.bash_private
fi

# vi: syntax=sh ts=2 noexpandtab
