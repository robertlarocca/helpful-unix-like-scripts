# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Helpful aliases for busybox sysadmins, developers and the forgetful.

# Script version and release
script_version='4.0.6'
script_release='release'  # options devel, beta, release, stable
export ASH_ALIASES_VERSION="$script_version-$script_release"

PATH="$PATH:/usr/local/sbin:/usr/local/bin"

# Purge the current shell session history and exit
# after removing files using the clean command.
clean() {
	# Unfortunately using the which command wont work here.
	# Must use the absolute path to clean script.
	/usr/local/bin/clean "$@"
	local clean_status="$?"

	if [[ "$SHELL" == "/bin/ash" ]]; then
		echo "Warning: Cannot purge ash (BusyBox) history buffer." 2>&1
	fi

	if [[ "$clean_status" -ge "5" ]]; then
		exit
	fi
}

alias swupdate="$(which swupdate) --opkg"
