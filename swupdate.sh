#!/bin/bash

# Copyright (c) 2023 Robert LaRocca https://www.laroccx.com

# Update apt packages, snaps, flatpaks, firmware or upgrade
# to the next operating system release.

# Script version and release
script_version='2.4.0'
script_release='release'  # options devel, beta, release, stable

require_root_privileges() {
	if [[ "$(whoami)" != "root" ]]; then
		# logger -i "Error: swupdate must be run as root!"
		echo "Error: swupdate must be run as root!" >&2
		exit 2
	fi
}

require_user_privileges() {
	if [[ "$(whoami)" == "root" ]]; then
		# logger -i "Error: swupdate must be run as normal user!"
		echo "Error: swupdate must be run as normal user!" >&2
		exit 2
	fi
}

show_help_message() {
	cat <<-EOF_XYZ
	Usage: swupdate [OPTION]...
	Easily update Debian and Red Hat based operating systems. All the
	installed packages and hardware firmware can be updated using this
	swupdate script and command wrapper utiltiy.

	This script by default (without an additional option provided) will
	update all of the installed packages and autoremove unused packages.
	The additional options provide more package sources and functionality.

	Options:
	 all - update packages, snaps, flatpaks and hardware firmware
	 apt - update only installed APT packages
	 dnf - update only installed RPM-based packages
	 firmware - update only the hardware firmware
	 flatpak - update only installed Flatpak packages
	 opkg - update only installed OpenWrt packages
	 python - update only installed Python3 packages
	 snap - update only installed Snap packages
	 wsl - update only the Windows Subsystem for Linux packages

	 normal - upgrade to the next current Ubuntu release
	 lts - upgrade to the next long term supported Ubuntu release
	 never - never upgrade to the next Ubuntu release

	 version - show version information
	 help - show this help message

	When using the normal or lts options; swupdate tries to upgrade Ubuntu with
	third party mirrors and repositories enabled instead of commenting out.

	Exit status:
	 0 - ok
	 1 - minor issue
	 2 - serious error

	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts

	See apt(8) dnf(8) fwupdmgr(1) snap(8) and do-release-upgrade(8) for
	additonal information and to provide insight how this wrapper works.
	EOF_XYZ
}

show_version_information() {
	cat <<-EOF_XYZ
	swupdate $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts
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

	if [[ -x $(which apt) ]]; then
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

	if [[ -x $(which dnf) ]]; then
		dnf clean all
		dnf check-update
		dnf --assumeyes upgrade
		# Don't remove any packages without prompting user.
		dnf autoremove
	elif [[ -x $(which yum) ]]; then
		yum clean all
		yum check-update
		yum --assumeyes upgrade
		# Don't remove any packages without prompting user.
		yum autoremove
	fi
}

flatpak_packages() {
	require_root_privileges

	if [[ -x $(which flatpak) ]]; then
		flatpak update
	fi
}

opkg_packages() {
	require_root_privileges

	if [[ -x $(which opkg) ]]; then
		opkg update
		local upgrade_list="$(opkg list-upgradable | awk '{ printf "%s ",$1 }' 2>/dev/null)"
		if [[ -n "$upgrade_list" ]]; then
			opkg install "$upgrade_list"
		else
			echo "All OpenWrt packages up to date."
		fi
	fi
}

python3_packages() {
	require_user_privileges

	if [[ -x $(which pip3) ]]; then
		local upgrade_list="$(pip3 list --outdated | cut -d' ' -f1 | tail -n+3 2> /dev/null)"
		if [[ -n "$upgrade_list" ]]; then
			pip3 install --upgrade "$upgrade_list"
		else
			echo "All Python packages up to date."
		fi
	fi
}

snap_packages() {
	require_root_privileges

	if [[ -x $(which snap) ]]; then
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
	local kernel_release="$(uname --kernel-release)"
	if [[ "$kernel_release" =~ .*"WSL".* ]]; then
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

	if [[ -x $(which fwupdmgr) ]]; then
		fwupdmgr --force refresh
		fwupdmgr update
	fi
}

os_upgrade() {
	local os_release="$1"
	require_root_privileges

	if [[ -x $(which apt) ]]; then
		apt --yes install update-manager-core
	fi

	cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
	sed -E -i s/'^Prompt=.*'/'Prompt=$os_release'/g /etc/update-manager/release-upgrades

	if [[ -x $(which do-release-upgrade) ]]; then
		do-release-upgrade --allow-third-party
	fi
}

# Options
case "$1" in
all)
	apt_packages
	dnf_packages
	opkg_packages
	flatpak_packages
	snap_packages
	wsl2_packages
	firmware_packages
	;;
apt)
	apt_packages
	;;
dnf | yum)
	dnf_packages
	;;
firmware)
	firmware_packages
	;;
flatpak)
	flatpak_packages
	;;
openwrt | opkg)
	opkg_packages
	;;
python | pip)
	python3_packages
	;;
snap)
	snap_packages
	;;
wsl)
	wsl2_packages
	;;
normal)
	os_upgrade "$1"
	;;
lts)
	os_upgrade "$1"
	;;
never)
	os_upgrade "$1"
	;;
version)
	show_version_information
	;;
help | --help)
	show_help_message
	;;
*)
	if [[ -z "$1" ]]; then
		apt_packages
		dnf_packages
		opkg_packages
		flatpak_packages
		snap_packages
	else
		error_unrecognized_option "$*"
		exit 1
	fi
	;;
esac

# vi: syntax=sh ts=2 noexpandtab
