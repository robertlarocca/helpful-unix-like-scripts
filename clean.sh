#!/usr/bin/env bash

# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Remove history files created using the GNU History Library.

# Script version and release
script_version='4.2.0'
script_release='beta'  # options devel, beta, release, stable

require_root_privileges() {
	if [[ "$(id -un)" != "root" ]]; then
			# logger -i "Error: clean must be run as root!"
			echo "Error: clean must be run as root!" >&2
			exit 2
	fi
}

show_help() {
	cat <<-EOF_XYZ
	Usage: clean [OPTION] [ACTION] <time> <message...>

	Remove all the known history files in the user home directory.

	Options:
	 -a, --all		remove all history files
	 -A, --most		remove most history files (default)
	 -w, --windows  remove Windows history files
	     --wsl      same as --windows
	 -v, --version  show version information
	 -h, --help     show this help message and exit

	Actions:
	 -c, --clear    clear screen
	 -e, --exit     exit shell session
	 --halt		    halt system
	 --reboot	    reboot system
	 --restart      same as --reboot
	 --shutdown     shutdown system
	 --poweroff     same as --shutdown
	 --sleep	    sleep system
	 --hibernate    same as --sleep

	The second argument must be a <time> string. The default value
	is 'now' which is interpeted as '+0'. This may be followed with
	a <wall> message. The message will be broadcasted to all users
	before the action (eg. reboot, shutdown, etc) is performed.

	Example Commands:
	 clean --all
	 clean -a
	 clean --most
	 clean -A
	 clean --wsl
	 clean --reboot now
	 clean --poweroff +5 "Poweroff initiated by clean.sh"

	History Files:
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

	Status Codes:
	 0 - OK
	 1 - Issue
	 2 - Error
	EOF_XYZ
}

show_version() {
	cat <<-EOF_XYZ
	clean $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	clean: unrecognized option '$1'
	Try 'clean --help' for more information.
	EOF_XYZ
	exit 1
}

remove_all() {
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

	history -c 2> /dev/null
	history -p 2> /dev/null
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

	history -c 2> /dev/null
	history -p 2> /dev/null
}

remove_windows_history() {
	logger -i "Notice: Removed powershell and recent file history from c:\Users\\$USER directory."
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadLine/ConsoleHost_history.txt
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/Recent/*.lnk
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/Recent/AutomaticDestinations/*
	rm -f /mnt/c/Users/$USER/AppData/Roaming/Microsoft/Windows/Recent/CustomDestinations/*

	history -c 2> /dev/null
	history -p 2> /dev/null
}

clear_screen() {
	clear 2> /dev/null
}

exit_shell() {
	exit 5
}

# Options
case "$1" in
--all | -a)
	remove_all
	remove_windows_history
	;;
--most | -A)
	remove_most
	;;
--windows | --wsl | -w)
	remove_windows_history
	;;
--halt)
	remove_most
	if [[ -z "$2" ]]; then
		sudo shutdown -h +0
	else
		sudo shutdown -h "$2" "$3"
	fi
	;;
--reboot)
	remove_most
	if [[ -z "$2" ]]; then
		sudo shutdown -r +0
	else
		sudo shutdown -r "$2" "$3"
	fi
	;;
--sleep | --hibernate)
	remove_most
	if [[ -z "$2" ]]; then
		sudo shutdown -s +0
	else
		sudo shutdown -s "$2" "$3"
	fi
	;;
--poweroff | --shutdown)
	remove_most
	if [[ -z "$2" ]]; then
		sudo shutdown --poweroff +0
	else
		sudo shutdown --poweroff "$2" "$3"
	fi
	;;
--version | -v)
	show_version
	;;
--help | -h)
	show_help
	;;
*)
	if [[ -z "$1" ]]; then
		remove_most
	else
		error_unrecognized_option "$*"
	fi
	;;
esac

# vi: syntax=sh ts=4 sw=4 sts=4 sr noet
