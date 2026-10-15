#!/usr/bin/env bash

# Copyright (c) 2026 Robert LaRocca <https://www.laroccx.com>

# Helper script (wrapper) to updates software packages across many popular Unix-like and Windows package managers
# including apt, dnf (and legacy yum), opkg, winget, pip3, snap, flatpak, brew, and port. Support for additional
# package managers is being added. The tool can also perform an in-place upgrade of Ubuntu-based operating systems
# to the next long-term support (LTS) or development release.

# Script version and release
SCRIPT_VERSION="4.3.0"
SCRIPT_RELEASE="release"  # options devel, alpha, beta, release, stable
SCRIPT_VERINFO="$SCRIPT_VERSION-$SCRIPT_RELEASE"

# Uncomment to enable bash xtrace mode.
# set -xv

OPTIONS_USER="$1"

# Check os-release variables.
if [ -f /etc/os-release ]; then
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
	Usage: swupdate [OPTIONS] [EXTRAS] ...

	Easily update Debian, Red Hat, and other Unix-like operating systems.
	This script updates installed packages and hardware firmware.

	The swupdate command, by default updates all installed packages and removes
	unused dependencies. Additional options enable access to more package sources
	and other built-in features.

	Options:
	 -a, --all      Update all packages, default, firmware, snap, brew, etc
	 --apt          Update apt Debian like packages
	 --dnf          Update dnf Red Hat like packages
	 --firmware     Update hardware firmware
	 --flatpak      Update Flatpak packages
	 --macos        Update App Store packages
	 --homebrew     Update Homebrew (brew) packages [Untested]
	 --macports     Update MacPorts (port) packages
	 --opkg         Update OpenWrt packages
	 --python       Update Python3 (pip3) packages
	 --snap         Update Snapcraft (snap) packages
	 --winget       Update Windows Package Manager packages
	 --wsl          Update Windows Subsystem for Linux system components
	 --yum          Update legacy yum CentOS and Red Hat packages

	Extras:
	 -f, --force    Always update packages, even if phased by system vendor
	 -h, --help     Show this help message and exit
	 -v, --version  Show version information and exit

	Notes:
	When using the Normal or Long-Term Support (LTS) options, swupdate will attempt
	to upgrade Debian and Ubuntu while leaving any third-party repositories enabled.

	Status:
	Like most Unix-like programs, the swupdate script returns an exit status code
	whenever it terminates. The status code reflects the reason for why the process
	ended and is passed to the calling shell.

	 0 - Successful
	 1 - Issue
	 2 - Error
	 3 - Unknown

	See apt(8) dnf(8) port(1) fwupdmgr(1) snap(8) and do-release-upgrade(8) for more
	information and provide detailed insight into how this wrapper script works.
	EOF_XYZ
}

show_version() {
	cat <<-EOF_XYZ
	swupdate $SCRIPT_VERINFO
	Copyright (c) $(date +%Y) Robert LaRocca <https://www.laroccx.com>
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	swupdate: unrecognized option '$OPTIONS_USER'
	Try 'swupdate --help' for more information.
	EOF_XYZ
}

apt_packages() {
	require_root_privileges;
	local extras_option="$2"

	if [[ "$ID_LIKE" == "debian" ]] && [[ -x $(command -v apt 2> /dev/null) ]]; then
		apt autoclean
		apt update

		case "$extras_option" in
		--force | -f)
			# Install any phased packages with updates
			apt --yes --option="APT::Get::Always-Include-Phased-Updates=true" upgrade
			apt --yes --option="APT::Get::Always-Include-Phased-Updates=true" full-upgrade
			;;
		*)
			if [[ -z "$extras_option" ]]; then
				# Do not install phased packages with updates
				apt --yes upgrade
				apt --yes full-upgrade
			else
				error_unrecognized_option "$*"
				exit 1
			fi
			;;
		esac

		# Do not remove any packages without prompting user.
		apt autoremove
	fi
}

dnf_packages() {
	require_root_privileges;

	if [[ "$ID_LIKE" == "fedora" ]] && [[ -x $(command -v dnf 2> /dev/null) ]]; then
		dnf clean all
		dnf check-update
		dnf --assumeyes upgrade
		# Don't remove any packages without prompting user.
		dnf autoremove
	elif [[ "$ID_LIKE" == "fedora" ]] && [[ -x $(command -v yum 2> /dev/null) ]]; then
		yum clean all
		yum check-update
		yum --assumeyes upgrade
		# Don't remove any packages without prompting user.
		yum autoremove
	fi
}

flatpak_packages() {
	require_root_privileges;

	if [[ -x $(command -v flatpak 2> /dev/null) ]]; then
		flatpak update
	fi
}

opkg_packages() {
	require_root_privileges;

	if [[ "$ID_LIKE" == "lede openwrt" ]] && [[ -x $(command -v opkg 2> /dev/null) ]]; then
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
	require_root_privileges;

	# Test for the macOS Darwin UNIX kernel.
	local kernel_os="$(uname -o 2> /dev/null)"

	if [[ "$kernel_os" =~ "Darwin" ]]; then
		if [[ -x $(command -v softwareupdate 2> /dev/null) ]]; then
			softwareupdate --install --all
		fi
	fi
}

homebrew_packages() {
	require_root_privileges;

	# Test for the macOS Darwin UNIX kernel.
	local kernel_os="$(uname -o 2> /dev/null)"

	if [[ "$kernel_os" =~ "Darwin" ]]; then
		if [[ -x $(command -v brew 2> /dev/null) ]]; then
			brew update
			brew --force-cleanup --no-ask upgrade
		fi
	fi
}

macports_packages() {
	require_root_privileges;

	# Test for the macOS Darwin UNIX kernel.
	local kernel_os="$(uname -o 2> /dev/null)"

	if [[ "$kernel_os" =~ "Darwin" ]]; then
		if [[ -x $(command -v port 2> /dev/null) ]]; then
			port -q -R selfupdate
			port -q -R upgrade outdated
		fi
	fi
}

python3_packages() {
	require_user_privileges

	if [[ -x $(command -v pip3 2> /dev/null) ]]; then
		local upgrade_list="$(pip3 list --outdated | cut -d' ' -f1 | tail -n+3 2> /dev/null)"
		if [[ -n "$upgrade_list" ]]; then
			pip3 install --upgrade $upgrade_list
		else
			echo "All Python packages up to date."
		fi
	fi
}

snapcraft_packages() {
	require_root_privileges;

	if [[ -x $(command -v snap 2> /dev/null) ]]; then
		snap refresh
	fi
}

winget_packages() {
	# Set absolute path to the winget.exe binary.
	# Using methods like command or which  do not work as root user
	local winget_binary="$NTHOME/AppData/Local/Microsoft/WindowsApps/winget.exe"
	if [[ -x "$(command -v winget.exe)" ]]; then
		# winget.exe source update
		winget.exe update --all
	fi
}

wsl_packages() {
	# Set complete path to the wsl.exe binary.
	# Using methods like command or which  do not work as root user.
	local wsl_binary="/mnt/c/WINDOWS/system32/wsl.exe"
	if [[ -x "$(command -v wsl.exe)" ]]; then
		wsl.exe --update
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
	require_root_privileges;
	error_kernel_release

	if [[ -x $(command -v fwupdmgr 2> /dev/null) ]]; then
		fwupdmgr --force refresh
		fwupdmgr update
	fi
}

os_upgrade() {
	# Use this function at your own risk!
	# You are better to directly use the do-release-upgrade command.
	local os_release="$1"
	require_root_privileges;

	if [[ -x $(command -v apt 2> /dev/null) ]]; then
		apt --yes install update-manager-core
	fi

	cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
	sed -E -i s/'^Prompt=.*'/'Prompt=$os_release'/g /etc/update-manager/release-upgrades

	if [[ -x $(command -v do-release-upgrade 2> /dev/null) ]]; then
		do-release-upgrade --allow-third-party
	fi
}

# Options
case "$OPTIONS_USER" in
--all | -a)
	apt_packages;
	dnf_packages;
	macos_packages;
	homebrew_packages;
	macports_packages;
	opkg_packages;
	flatpak_packages;
	snapcraft_packages;
	winget_packages;
	wsl_packages;
	firmware_packages;
	;;
--apt | --apt-get)
	apt_packages;
	;;
--dnf | --yum)
	dnf_packages;
	;;
--firmware | --fw | --eprom)
	firmware_packages;
	;;
--flatpak)
	flatpak_packages;
	;;
--openwrt | --opkg)
	opkg_packages;
	;;
--macos)
	macos_packages;
	;;
--brew | --homebrew)
	homebrew_packages;
	;;
--ports | --macports)
	macports_packages;
	;;
--python | --python3 | --pip | pip3)
	python3_packages
	;;
--snap | --snapcraft)
	snapcraft_packages;
	;;
--winget)
	winget_packages;
	;;
--wsl | --wsl2)
	wsl_packages;
	;;
--version | -v)
	show_version
	;;
--help | -h)
	show_help;
	;;
*)
	if [[ -z "$OPTIONS_USER" ]]; then
		apt_packages;
		dnf_packages;
		macos_packages;
		opkg_packages;
		flatpak_packages;
		snapcraft_packages;
	else
		error_unrecognized_option "$*";
		exit 1
	fi
	;;
esac

exit 0

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
