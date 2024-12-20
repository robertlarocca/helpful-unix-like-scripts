#!/usr/bin/env bash

# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Customize the GNOME desktop enviroment theme and application settings.

# Script version and release
script_version='4.1.0'
script_release='release'  # options devel, beta, release, stable

require_root_privileges() {
	if [[ "$(id -un)" != "root" ]]; then
		# logger -i "Error: theme-helper must be run as root!"
		echo "Error: theme-helper must be run as root!" >&2
		exit 2
	fi
}

require_user_privileges() {
	if [[ "$(id -un)" == "root" ]]; then
		# logger -i "Error: theme-helper must be run as normal user!"
		echo "Error: theme-helper must be run as normal user!" >&2
		exit 2
	fi
}

show_help() {
	cat <<-EOF_XYZ
	Usage: theme-helper [OPTION]...

	Easily customize the GNOME desktop environment theme and application
	settings. This script also configures apt (dpkg) post-invoke to run
	after installing and upgrading packages.

	Options:
	 -a, --all   configure and customize applications, auto invoke theme-helper
	 -A, --auto  invoke theme-helper after apt packages are installed
	 --config    configure GNOME desktop and GTK settings
	 --custom    customize select applications exec, icon, name etc
	 --hide      hide select applications

	 -v, --version  show version and exit
	 -h, --help - show this help message and exit

	When using theme-helper 'Yaru-Dark' is the default appearance style
	and 'fingers' is the default click-method for touchpad peripherals.

	Status Codes:
	 0 - OK
	 1 - Issue
	 2 - Error

	See apt(8) apt-config(8) dpkg(1) dpkg-reconfigure(8) for additional
	information and to provide insight how this wrapper works.
	EOF_XYZ
}

show_version() {
	cat <<-EOF_XYZ
	theme-helper $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	theme-helper: unrecognized option '$1'
	Try 'theme-helper --help' for more information.
	EOF_XYZ
}

configure_dpkg_invoke() {
	if [[ ! -f "/etc/apt/apt.conf.d/80theme-helper" ]]; then
		cat <<-EOF_XYZ > /etc/apt/apt.conf.d/80theme-helper
		# Customize the GNOME desktop environment theme and application settings.
		DPkg::Post-Invoke {"$(which $0) 2> /dev/null";};
		EOF_XYZ
	fi
}

configure_gsettings() {
	if [[ -x $(which gsettings 2> /dev/null) ]]; then
		gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark' 2> /dev/null
		gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers' 2> /dev/null
	fi
}

customize_applications() {
	sed -E -i s/'Name=Microsoft Edge'/'Name=Browser'/g /usr/share/applications/microsoft-edge.desktop
	sed -E -i s/'^Icon=.*'/'Icon=webbrowser-app'/g /usr/share/applications/microsoft-edge.desktop
	sed -E -i s/'Exec=\/usr\/bin\/microsoft-edge-stable'/'Exec=\/usr\/bin\/microsoft-edge-stable --force-dark-mode'/g /usr/share/applications/microsoft-edge.desktop

	# sed -E -i s/'Name=Microsoft Teams'/'Name=Teams'/g /usr/share/applications/teams.desktop
	# sed -E -i s/'^Icon=.*'/'Icon=camera-app'/g /usr/share/applications/teams.desktop

	sed -E -i s/'Name=Microsoft Teams'/'Name=Teams'/g /home/robert/.local/share/applications/msedge-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop
	sed -E -i s/'^Icon=.*'/'Icon=camera-app'/g /home/robert/.local/share/applications/msedge-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop

	sed -E -i s/'Name=Visual Studio Code'/'Name=Code'/g /usr/share/applications/code.desktop
	sed -E -i s/'^Icon=.*'/'Icon=accessories-text-editor'/g /usr/share/applications/code.desktop

	sed -E -i s/'Name=Remmina'/'Name=Remmina'/g /usr/share/applications/org.remmina.Remmina.desktop
	sed -E -i s/'^Icon=.*'/'Icon=org.remmina.Remmina'/g /usr/share/applications/org.remmina.Remmina.desktop

	sed -E -i s/'Name=Geary'/'Name=Mail'/g /usr/share/applications/org.gnome.Geary.desktop
	sed -E -i s/'^Icon=.*'/'Icon=mail-app'/g /usr/share/applications/org.gnome.Geary.desktop

	sed -E -i s/'Name=Element'/'Name=Messages'/g /usr/share/applications/element-desktop.desktop
	sed -E -i s/'^Icon=.*'/'Icon=messaging-app'/g /usr/share/applications/element-desktop.desktop

	sed -E -i s/'Name=Rhythmbox'/'Name=Music'/g /usr/share/applications/org.gnome.Rhythmbox3.desktop
	sed -E -i s/'Name=Rhythmbox'/'Name=Music'/g /usr/share/applications/org.gnome.Rhythmbox3.device.desktop
	sed -E -i s/'^Icon=.*'/'Icon=rhythmbox'/g /usr/share/applications/org.gnome.Rhythmbox3.desktop
	sed -E -i s/'^Icon=.*'/'Icon=rhythmbox'/g /usr/share/applications/org.gnome.Rhythmbox3.device.desktop

	sed -E -i s/'Name=Disk Usage Analyzer'/'Name=Disk Usage'/g /usr/share/applications/org.gnome.baobab.desktop
	sed -E -i s/'Name=Disks'/'Name=Disk Utility'/g /usr/share/applications/org.gnome.DiskUtility.desktop
	sed -E -i s/'Name=Passwords and Keys'/'Name=Keyring'/g /usr/share/applications/org.gnome.seahorse.Application.desktop
	sed -E -i s/'Name=Power Statistics'/'Name=Power Stats'/g /usr/share/applications/org.gnome.PowerStats.desktop
	sed -E -i s/'Name=Startup Applications'/'Name=Startup Apps'/g /usr/share/applications/gnome-session-properties.desktop
	sed -E -i s/'Name=Ubuntu Software'/'Name=Software'/g /var/lib/snapd/desktop/applications/snap-store_ubuntu-software.desktop

	sed -E -i s/'^Icon=.*'/'Icon=games-app'/g /usr/share/applications/org.gnome.Games.desktop
}

hide_applications() {
	for i in \
		/usr/share/applications/byobu.desktop \
		/usr/share/applications/gnome-language-selector.desktop \
		/usr/share/applications/htop.desktop \
		/usr/share/applications/im-config.desktop \
		/usr/share/applications/info.desktop \
		/usr/share/applications/nm-connection-editor.desktop \
		/usr/share/applications/org.gnome.eog.desktop \
		/usr/share/applications/org.gnome.Evince.desktop \
		/usr/share/applications/software-properties-drivers.desktop \
		/usr/share/applications/software-properties-gtk.desktop \
		/usr/share/applications/update-manager.desktop \
		/usr/share/applications/vim.desktop \
		; do

		if [[ -s "$i" ]]; then
			if [[ "$(grep --count 'NoDisplay=true' "$i" 2> /dev/null)" == "0" ]]; then
				echo 'NoDisplay=true' >> "$i"
			fi
		fi
	done
}

# Options
case "$1" in
--all | -a)
	configure_dpkg_invoke
	configure_gsettings
	customize_applications
	hide_applications
	;;
--auto | -A)
	configure_dpkg_invoke
	;;
--config)
	configure_gsettings
	;;
--custom)
	customize_applications
	;;
--hide)
	hide_applications
	;;
--version | -v)
	show_version
	;;
--help | -h)
	show_help
	;;
*)
	if [[ -z "$1" ]]; then
	configure_gsettings
	customize_applications
	hide_applications
	else
		error_unrecognized_option "$*"
		exit 1
	fi
	;;
esac

exit 0

# vi: syntax=sh ts=2 noexpandtab
