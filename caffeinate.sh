#!/usr/bin/env bash

# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Prevent idle system sleep (blank screen), suspend, and hibernation
# until reboot. Similar to the macOS 'caffeinate' command.

# Script version and release
script_version='4.1.0'
script_release='release'  # options devel, beta, release, stable

# Setting blank_screen_delay to 0 (zero) disables the feature.
blank_screen_delay_on="3600" # default is 3600 seconds
blank_screen_delay_off="300" # default is 300 seconds

require_root_privileges() {
	if [[ "$(id -un)" != "root" ]]; then
		# logger -i "Error: caffeinate must be run as root!"
		echo "Error: caffeinate must be run as root!" >&2
		exit 2
	fi
}

show_help() {
	cat <<-EOF_XYZ
	Usage: caffeinate [OPTION]...

	Prevent this system from entering sleep, suspend and hibernate targets.

	This script by default (without an additional option provided) will
	prevent idle power management until the next reboot or disabled.

	Options:
	 -1, --enable   prevent idle sleep, suspend and hibernate
	 -0, --disable  restore idle sleep, suspend and hibernate
	 -s, --status   show the current state of caffeinate

	 -v, --version  show version and exit
	 -h, --help     show this help message and exit

	Status Codes:
	 0 - OK
	 1 - Issue
	 2 - Error

	See systemctl(1) for additonal information and to provide insight
	how this script works.
	EOF_XYZ
}

show_version() {
	cat <<-EOF_XYZ
	caffeinate $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	caffeinate: unrecognized option '$1'
	Try 'caffeinate --help' for more information.
	EOF_XYZ
}

# Options
case "$1" in
--enable | -1)
	gsettings set org.gnome.desktop.session idle-delay $blank_screen_delay_on

	sudo systemctl --runtime mask \
		sleep.target \
		suspend.target \
		suspend-then-hibernate.target \
		hybrid-sleep.target \
		hibernate.target > /dev/null

	touch $HOME/.caffeinate
	PS1="☕ $PS1_ORIG"
	;;
--disable | -0)
	gsettings set org.gnome.desktop.session idle-delay $blank_screen_delay_off

	sudo systemctl --runtime unmask \
		sleep.target \
		suspend.target \
		suspend-then-hibernate.target \
		hybrid-sleep.target \
		hibernate.target > /dev/null

	if [[ -f "$HOME/.caffeinate" ]]; then
		rm -f $HOME/.caffeinate
	fi

	set_emoji_ps1_prompt
	;;
--status | -s)
	echo "Period of inactivity after which the screen will go blank."
	echo "    Blank Screen Delay: $(gsettings get org.gnome.desktop.session idle-delay) " && echo

	systemctl -l status \
		sleep.target \
		suspend.target \
		suspend-then-hibernate.target \
		hybrid-sleep.target \
		hibernate.target \
		| tee
	;;
--version | -v)
	show_version
	;;
--help | -h)
	show_help
	;;
*)
	if [[ -z "$1" ]]; then
		gsettings set org.gnome.desktop.session idle-delay $blank_screen_delay_on

		sudo systemctl --runtime mask \
			sleep.target \
			suspend.target \
			suspend-then-hibernate.target \
			hybrid-sleep.target \
			hibernate.target > /dev/null

		touch $HOME/.caffeinate
		PS1="☕ $PS1_ORIG"
	else
		error_unrecognized_option "$*"
		exit 1
	fi
	;;
esac

# vi: syntax=sh ts=4 sw=4 sts=4 sr noet
