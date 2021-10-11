#!/bin/bash

# Copyright (c) 2021 Robert LaRocca http://www.laroccx.com

# Helpful Linux bash_aliases for sysadmins, developers and the forgetful.

export BASH_ALIASES_VERSION="1.4.0-$HOSTNAME"

if [ $USER = 'root' ]; then
	printf '🧀 '
elif [ $USER = 'user1' ]; then
	printf '👾️ '
elif [ $USER = 'user2' ]; then
	printf '💵️ '
fi

# Edit bash aliases using gedit (Text Editor)
bashedit() {
	case "$1" in
	--code)
		code $HOME/.bash_aliases
		;;
	--gedit)
		gedit $HOME/.bash_aliases
		;;
	--nano)
		nano $HOME/.bash_aliases
		;;
	--vi | --vim)
		vim $HOME/.bash_aliases
		;;
	*)
		$(which xdg-open) $HOME/.bash_aliases
		;;
	esac
}

# Prevent pubkey authentication with ssh and scp commands
alias ssh-passwd="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias scp-passwd="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

# Prevent conflicts with existing kubectl installs
alias kubectl="microk8s kubectl"

# Similar to the macOS 'open' command
alias open="$(which xdg-open)"

# Search bash history with grep
alias hgrep="history | grep -i"

# Display the current ipv4 and ipv6 address
whatsmyip() {
	ipv4_address="$(curl -s4 https://ifconfig.co/ip)"
	ipv6_address="$(curl -s6 https://ifconfig.co/ip)"

	if [ -n "$ipv4_address" ]; then
		echo "IPv4: $ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo "IPv6: $ipv6_address"
	fi
}

# Display the current logical volume management (lvs) storage
lvms() {
	# Require root privileges
	if [ $UID != 0 ]; then
		logger -i "Error: lvms must be run as root!"
		echo "Error: lvms must be run as root!"
	else
		echo '  --- Physical volumes ---'
		pvs
		echo
		echo '  --- Volume groups ---'
		vgs
		echo
		echo '  --- Logical volumes ---'
		lvs
		echo
	fi
}

lvmdisplay() {
	# Require root privileges
	if [ $UID != 0 ]; then
		logger -i "Error: lvmdisplay must be run as root!"
		echo "Error: lvmdisplay must be run as root!"
	else
		pvdisplay
		vgdisplay
		lvdisplay
	fi
}

# Display command reminder to create a lvm snapshot
lvmsnapshot() {
	cat <<-EOF_XYZ
		Logical volume snapshots are created using the 'lvcreate' command.

		Examples:
		 lvcreate -L 50%ORIGIN --snapshot --name snap_1 /dev/mapper/ubuntu-root
		 lvcreate -L 16G -s -n snap_2 /dev/ubuntu/logical-volume-name

		See the lvcreate(8) manual for more information.
	EOF_XYZ
}

# Generate a secure random password
alias mkpw="mkpassword"
mkpassword() {
	local a=$(pwgen -A -0 -B 6 1)
	local b=$(pwgen -A -0 -B 6 1)
	local c=$(pwgen -n -B 6 1)
	echo "$a-$b-$c"
}

# Generate a secure random pre-shared key
alias mkpsk="mkpresharedkey"
mkpresharedkey() {
	local a=$(pwgen -A -0 -B 6 1)
	local b=$(pwgen -A -0 -B 6 1)
	local c=$(pwgen -n -B 6 1)
	echo "$a-$b-$c" | sha256sum | cut -f1 -d' '
}

# Update apt repositories and upgrade installed packages
swupdate() {
	case "$1" in
	all)
		sudo apt --yes clean
		sudo apt --yes update
		sudo apt --yes upgrade
		sudo apt --yes full-upgrade
		sudo apt --yes autoremove
		sudo snap refresh
		sudo fwupdmgr --force refresh
		sudo fwupdmgr update
		;;
	firmware | fw)
		sudo fwupdmgr --force refresh
		sudo fwupdmgr update
		;;
	never)
		sudo apt --yes clean
		sudo apt --yes update
		sudo apt --yes upgrade
		sudo apt --yes full-upgrade
		sudo apt --yes autoremove
		sudo snap refresh
		sudo apt --yes install update-manager-core
		sudo cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
		sudo sed -E -i s/'^Prompt=.*'/'Prompt=never'/g /etc/update-manager/release-upgrades
		sudo do-release-upgrade
		;;
	normal | current)
		sudo apt --yes clean
		sudo apt --yes update
		sudo apt --yes upgrade
		sudo apt --yes full-upgrade
		sudo apt --yes autoremove
		sudo snap refresh
		sudo apt --yes install update-manager-core
		sudo cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
		sudo sed -E -i s/'^Prompt=.*'/'Prompt=normal'/g /etc/update-manager/release-upgrades
		sudo do-release-upgrade
		;;
	lts | longterm)
		sudo apt --yes clean
		sudo apt --yes update
		sudo apt --yes upgrade
		sudo apt --yes full-upgrade
		sudo apt --yes autoremove
		sudo snap refresh
		sudo apt --yes install update-manager-core
		sudo cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
		sudo sed -E -i s/'^Prompt=.*'/'Prompt=lts'/g /etc/update-manager/release-upgrades
		sudo do-release-upgrade
		;;
	help | --help)
		cat <<-EOF_XYZ
		swupdate $BASH_ALIASES_VERSION
		Usage: swupdate [option]

		swupdate is a apt commandline package manager wrapper and provides commands
		for quickly updating Debian and Ubuntu based operating systems.

		This command by default (without an option) will update all installed
		packages or snaps and autoremove all unused packages.

		Available options:
		  all - update installed packages, snaps and hardware firmware
		  firmware - update hardware firmware
		  never - update installed packages, snaps but never upgrade to next release
		  normal - update installed packages, snaps and upgrade to current release
		  lts - update installed packages, snaps and upgrade to current lts release
		  help - show help message and exit

		See apt(8) fwupdmgr(1) snap(8) and do-release-upgrade(8) for additonal
		information and insight into the available commands. Configuration options and
		syntax is detailed in '$HOME/.bash_aliases'.

		Copyright (c) 2021 Robert LaRocca http://www.laroccx.com
		EOF_XYZ
		;;
	*)
		if [ -z "$1" ]; then
			sudo apt --yes clean
			sudo apt --yes update
			sudo apt --yes upgrade
			sudo apt --yes full-upgrade
			sudo apt --yes autoremove
			sudo snap refresh
		else
			cat <<-EOF_XYZ
				swupdate: unrecognized option '$1'
				Try 'swupdate --help' for more information.
			EOF_XYZ
		fi
		;;
	esac
}

# Check website availability
alias check-website="test-website"
test-website() {
	local server_address="$1"

	if [ -n "$server_address" ]; then
		echo "$server_address"
		curl -ISs --connect-timeout 8 --retry 2 "$server_address"
	else
		for server_address in \
			https://www.bing.com \
			https://duckduckgo.com \
			https://www.google.com \
			https://www.yahoo.com; do
			echo "$server_address"
			curl -ISs --connect-timeout 8 --retry 2 "$server_address"
			echo
		done
	fi
}

# Test firewall ports using telnet
test-port() {
	local server_address='telnet.example.com'
	local service_port='8738'

	case "$1" in
	-p | --port)
		telnet $server_address "$2"
		;;
	*)
		if [ -z "$1" ]; then
			telnet $server_address $service_port
		else
			cat <<-EOF_XYZ
				test-port: unrecognized option '$1'
				Try 'test-port --port <number>' to check a specific port.
			EOF_XYZ
		fi
		;;
	esac
}

# Merge current master with upstream
git-merge-upstream() {
	case "$1" in
	-H | --help)
		cat <<-EOF_XYZ
			Update a fork by merging with upstream using the 'git' command.

			Examples:
			 remote add upstream https://example.com/project-repo.git
			 git fetch upstream
			 git checkout master
			 git merge upstream/master
			 git push origin master

			See gittutorial(7) and the git(1) manual for more information.
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
alias wifi-power="wlan-power"
wlan-power() {
	if [ -z "$1" ]; then
		iwconfig wlan0
	else
		sudo iwconfig wlan0 power "$1"
	fi
}

# Ookla speedtest-cli alias to display minimal output
alias speedtest="speedtest-cli --simple"

# Include private bash_aliases
if [ -f "$HOME/.bash_aliases_private" ]; then
	source $HOME/.bash_aliases_private
fi
