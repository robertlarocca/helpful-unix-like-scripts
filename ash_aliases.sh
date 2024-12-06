# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Helpful aliases for busybox sysadmins, developers and the forgetful.

# Script version and release
script_version='4.0.5'
script_release='release'  # options devel, beta, release, stable
export ASH_ALIASES_VERSION="$script_version-$script_release"

PATH="$PATH:/usr/local/sbin:/usr/local/bin"

# Purge the current shell session history after removing
# files using the clean command.
clean() {
	# Unfortunately using the which command wont work here.
	# Must use the absolute path to clean script.
	/usr/local/bin/clean "$@"
	local exit_shell="$?"

	if [[ "$SHELL" == "/bin/ash" ]]; then
		clear
		echo "Warning: Cannot purge ash (busybox) history buffer." 2>&1
		if [[ $exit_shell == "5" ]]; then
			sleep 1
			exit
		fi
	elif [[ "$SHELL" == "/bin/bash" ]]; then
		history -c
		if [[ $exit_shell == "5" ]]; then
			sleep 1
			exit
		fi
	elif [[ "$SHELL" == "/bin/zsh" ]]; then
		history -p
		if [[ $exit_shell == "5" ]]; then
			sleep 1
			exit
		fi
	fi
}

alias swupdate="$(which swupdate) --opkg"
