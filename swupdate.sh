#!/usr/bin/env bash

# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Update apt packages, snaps, flatpaks, firmware or upgrade
# to the next operating system release.

# Script version and release
script_version='4.1.0'
script_release='release'  # options devel, beta, release, stable

# Uncomment to enable bash xtrace mode.
# set -xv

# Check os-release variables.
if [[ -f /etc/os-release ]]; then
	# logger -i "Operating system release variables are available!"
	source /etc/os-release
fi

require_root_privileges() {
	if [[ "$(id -un)" != "root" ]]; then
		# logger -i "Error: swupdate must be run as root!"
		echo "Error: swupdate must be run as root!" >&2
		exit 2
	fi
}

require_user_privileges() {
	if [[ "$(id -un)" == "root" ]]; then
		# logger -i "Error: swupdate must be run as normal user!"
		echo "Error: swupdate must be run as normal user!" >&2
		exit 2
	fi
}

show_help() {
	cat <<-EOF_XYZ
	Usage: swupdate [OPTION]...

	Easily update Debian and Red Hat based operating systems. All the
	installed packages and hardware firmware can be updated using this

	This script by default (without an additional option provided) will
	update all of the installed packages and autoremove unused packages.
	The additional options provide more package sources and functionality.

	Options:
	 -a, --all   update all packages, Flatpaks, Snaps and firmware
	 --apt       update apt (aka Debian) packages
	 --dnf       update dnf and yum (aka Red Hat) packages
	 --firmware  update hardware firmware
	 --flatpak   update Flatpak packages
	 --macos     update App Store and MacPorts (aka port) packages
	 --opkg      update OpenWrt (aka opkg) packages
	 --python    update Python3 (aka pip3) packages
	 --snap      update Snap packages
	 --wsl       update Windows Subsystem for Linux packages

	 -v, --version  show version and exit
	 -h, --help     show this help message and exit

	When using the normal or lts options; swupdate tries to upgrade Ubuntu with
	third party mirrors and repositories enabled instead of commenting out.

	Status Codes:
	 0 - OK
	 1 - Issue
	 2 - Error

	See apt(8) dnf(8) port(1) fwupdmgr(1) snap(8) and do-release-upgrade(8)
	for additional information and to provide insight how this wrapper works.
	EOF_XYZ
}

show_version() {
	cat <<-EOF_XYZ
	swupdate $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	swupdate: unrecognized option '$1'
	Try 'swupdate --help' for more information.
	EOF_XYZ
}

apt_packages() {
	require_root_privileges

	if [[ "$ID_LIKE" == "debian" ]] && [[ -x $(which apt 2> /dev/null) ]]; then
		apt autoclean
		apt update
		apt --yes upgrade
		apt --yes full-upgrade
		# Don't remove any packages without prompting user.
		apt autoremove
	fi
}

dnf_packages() {
	require_root_privileges

	if [[ "$ID_LIKE" == "fedora" ]] && [[ -x $(which dnf 2> /dev/null) ]]; then
		dnf clean all
		dnf check-update
		dnf --assumeyes upgrade
		# Don't remove any packages without prompting user.
		dnf autoremove
	elif [[ "$ID_LIKE" == "fedora" ]] && [[ -x $(which yum 2> /dev/null) ]]; then
		yum clean all
		yum check-update
		yum --assumeyes upgrade
		# Don't remove any packages without prompting user.
		yum autoremove
	fi
}

flatpak_packages() {
	require_root_privileges

	if [[ -x $(which flatpak 2> /dev/null) ]]; then
		flatpak update
	fi
}

opkg_packages() {
	require_root_privileges

	if [[ "$ID_LIKE" == "lede openwrt" ]] && [[ -x $(which opkg 2> /dev/null) ]]; then
		opkg update
		local upgrade_list="$(opkg list-upgradable | awk '{ printf "%s ",$1 }' 2>/dev/null)"
		if [[ -n "$upgrade_list" ]]; then
			opkg install $upgrade_list
		else
			echo "All OpenWrt packages up to date."
		fi
	fi
}

macos_packages() {
	require_root_privileges

	# Test for the macOS Darwin UNIX kernel.
	local kernel_os="$(uname -o 2> /dev/null)"

	if [[ "$kernel_os" =~ "Darwin" ]]; then
		if [[ -x $(which port 2> /dev/null) ]]; then
			port -q -R selfupdate
			port -q -R upgrade outdated
		fi

		if [[ -x $(which softwareupdate 2> /dev/null) ]]; then
			softwareupdate --install --all
		fi
	fi
}

port_packages() {
	require_root_privileges

	if [[ -x $(which port 2> /dev/null) ]]; then
		port -q selfupdate
		port -q upgrade outdated
	fi
}

python3_packages() {
	require_user_privileges

	if [[ -x $(which pip3 2> /dev/null) ]]; then
		local upgrade_list="$(pip3 list --outdated | cut -d' ' -f1 | tail -n+3 2> /dev/null)"
		if [[ -n "$upgrade_list" ]]; then
			pip3 install --upgrade $upgrade_list
		else
			echo "All Python packages up to date."
		fi
	fi
}

snap_packages() {
	require_root_privileges

	if [[ -x $(which snap 2> /dev/null) ]]; then
		snap refresh
	fi
}

wsl2_packages() {
	# Set complete path to the Windows Subsystem for Linux binary.
	# Using methods like the which command don't work as root.
	local wsl_binary="/mnt/c/WINDOWS/system32/wsl.exe"
	if [[ -x "$wsl_binary" ]]; then
		$wsl_binary --update
	fi
}

error_kernel_release() {
	# Test for the Microsoft Standard Windows Subsystem for Linux (WSL) kernel.
	local kernel_release="$(uname -r 2> /dev/null)"
	if [[ "$kernel_release" =~ .*"WSL2" ]] ; then
		cat <<-EOF_XYZ >&2
		The following kernel is not supported by fwupdmgr:
		  $kernel_release
		EOF_XYZ
		exit 1
	fi
}

firmware_packages() {
	require_root_privileges
	error_kernel_release

	if [[ -x $(which fwupdmgr 2> /dev/null) ]]; then
		fwupdmgr --force refresh
		fwupdmgr update
	fi
}

os_upgrade() {
	# Use this function at your own risk!
	# You are better to directly use the do-release-upgrade command.
	local os_release="$1"
	require_root_privileges

	if [[ -x $(which apt 2> /dev/null) ]]; then
		apt --yes install update-manager-core
	fi

	cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
	sed -E -i s/'^Prompt=.*'/'Prompt=$os_release'/g /etc/update-manager/release-upgrades

	if [[ -x $(which do-release-upgrade 2> /dev/null) ]]; then
		do-release-upgrade --allow-third-party
	fi
}

# Options
case "$1" in
--all | -a)
	apt_packages
	dnf_packages
	macos_packages
	opkg_packages
	flatpak_packages
	snap_packages
	wsl2_packages
	firmware_packages
	;;
--apt)
	apt_packages
	;;
--dnf | --yum)
	dnf_packages
	;;
--firmware | --fw)
	firmware_packages
	;;
--flatpak)
	flatpak_packages
	;;
--openwrt | --opkg)
	opkg_packages
	;;
--macos)
	macos_packages
	;;
--python | --pip)
	python3_packages
	;;
--snap)
	snap_packages
	;;
--wsl | --wsl2)
	wsl2_packages
	;;
--version | -v)
	show_version
	;;
--help | -h)
	show_help
	;;
*)
	if [[ -z "$1" ]]; then
		apt_packages
		dnf_packages
		macos_packages
		opkg_packages
		flatpak_packages
		snap_packages
	else
		error_unrecognized_option "$*"
		exit 1
	fi
	;;
esac

# vi: syntax=sh ts=4 sw=4 sts=4 sr noet
