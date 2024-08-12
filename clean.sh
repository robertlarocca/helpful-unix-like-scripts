#!/usr/bin/env bash

# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Remove history files created using the GNU History Library.

# Script version and release
script_version='4.0.0'
script_release='release'  # options devel, beta, release, stable

require_root_privileges() {
	if [[ "$(id -un)" != "root" ]]; then
			# logger -i "Error: clean must be run as root!"
			echo "Error: clean must be run as root!" >&2
			exit 2
	fi
}

show_help_message() {
	cat <<-EOF_XYZ
	Usage: clean [OPTION] [TIME] [WALL]...
	Remove all the known history files in the user home directory.

	Options:
	 --all		remove all shell history files
	 --most		remove most shell history files
	 --halt		clean most shell history files and halt
	 --reboot	clean most shell history files and reboot
	 --shutdown	clean most shell history files and shutdown (or --poweroff)
	 --sleep	clean most shell history files and sleep
	 --windows	remove most Windows history files

	 --version	show version information
	 --help		show this help message

	The second argument must be a [TIME] string. The default value
	is 'now' which is interpeted as '+0'. This may be followed with
	a [WALL] message. If included the message will be broadcasted
	to users before shutdown.

	Examples:
	 clean --all
	 clean --most
	 clean --windows
	 clean --reboot now
	 clean --poweroff +5 "Poweroff initiated by clean.sh"

	History files:
	 ansible
	 bash_history
	 bash_sessions
	 lesshst
	 mysql_history
	 nano search_history
	 psql_history
	 python_history
	 rediscli_history
	 viminfo
	 wget-hsts
	 zsh_history
	 zsh_sessions

	Exit status:
	 0 - ok
	 1 - minor issue
	 2 - serious error

	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-macos-shell-scripts
	EOF_XYZ
}

show_version_information() {
	cat <<-EOF_XYZ
	clean $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-macos-shell-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	clean: unrecognized option '$1'
	Try 'clean --help' for more information.
	EOF_XYZ
	exit 1
}

remove_all_history() {
	logger -i "Notice: Removed all $(basename $SHELL) and command history from $HOME directory."
	rm -f -r $HOME/.ansible
	rm -f -r $HOME/.bash_sessions
	rm -f -r $HOME/.zsh_sessions
	rm -f $HOME/.bash_history
	rm -f $HOME/.lesshst
	rm -f $HOME/.local/share/nano/search_history
	rm -f $HOME/.motd_shown
	rm -f $HOME/.mysql_history
	rm -f $HOME/.psql_history
	rm -f $HOME/.python_history
	rm -f $HOME/.rediscli_history
	rm -f $HOME/.selected_editor
	rm -f $HOME/.sudo_as_admin_successful
	rm -f $HOME/.viminfo
	rm -f $HOME/.wget-hsts
	rm -f $HOME/.zsh_history

	if [[ "$SHELL" == "/bin/bash" ]]; then
		history -c
		clear
	elif [[ "$SHELL" == "/bin/zsh" ]]; then
		history -p
		clear
	fi
}

remove_most_history() {
	logger -i "Notice: Removed $(basename $SHELL) and command history from $HOME directory."
	rm -f -r $HOME/.bash_sessions
	rm -f -r $HOME/.zsh_sessions
	rm -f $HOME/.bash_history
	rm -f $HOME/.lesshst
	rm -f $HOME/.mysql_history
	rm -f $HOME/.psql_history
	rm -f $HOME/.python_history
	rm -f $HOME/.rediscli_history
	rm -f $HOME/.wget-hsts
	rm -f $HOME/.zsh_history

	if [[ "$SHELL" == "/bin/bash" ]]; then
		history -c
		clear
	elif [[ "$SHELL" == "/bin/zsh" ]]; then
		history -p
		clear
	fi
}

remove_windows_history() {
	logger -i "Notice: Removed powershell and recent file history from c:\Users\\$USER directory."
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadLine/ConsoleHost_history.txt
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/Recent/*.lnk
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/Recent/AutomaticDestinations/*
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/Recent/CustomDestinations/*

	if [[ "$SHELL" == "/bin/bash" ]]; then
		history -c
		clear
	elif [[ "$SHELL" == "/bin/zsh" ]]; then
		history -p
		clear
	fi
}

# Options
case "$1" in
--all)
	remove_all_history
	remove_windows_history
	;;
--most)
	remove_most_history
	;;
--windows | --wsl)
	remove_windows_history
	;;
--halt)
	remove_most_history
	if [[ -z "$2" ]]; then
		sudo shutdown -h +0
	else
		sudo shutdown -h "$2" "$3"
	fi
	;;
--reboot)
	remove_most_history
	if [[ -z "$2" ]]; then
		sudo shutdown -r +0
	else
		sudo shutdown -r "$2" "$3"
	fi
	;;
--sleep)
	remove_most_history
	if [[ -z "$2" ]]; then
		sudo shutdown -s +0
	else
		sudo shutdown -s "$2" "$3"
	fi
	;;
--poweroff | --shutdown)
	remove_most_history
	if [[ -z "$2" ]]; then
		sudo shutdown --poweroff +0
	else
		sudo shutdown --poweroff "$2" "$3"
	fi
	;;
--version)
	show_version_information
	;;
--help)
	show_help_message
	;;
*)
	if [[ -z "$1" ]]; then
		remove_most_history
	else
		error_unrecognized_option "$*"
	fi
	;;
esac

# vi: syntax=sh ts=2 noexpandtab
