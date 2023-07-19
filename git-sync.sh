#!/bin/bash

# Copyright (c) 2023 Robert LaRocca <robert@laroccx.com>

# Synchronize all Git repositories in the current directory or the list of directories.

# Script version and release
script_version='1.0.4'
script_release='beta'  # options devel, beta, release, stable

# Uncomment to enable bash xtrace mode.
# set -xv

require_root_privileges() {
	if [[ "$(whoami)" != "root" ]]; then
		# logger -i "Error: git-sync must be run as root!"
		echo "Error: git-sync must be run as root!" >&2
		exit 2
	fi
}

require_user_privileges() {
	if [[ "$(whoami)" == "root" ]]; then
		# logger -i "Error: git-sync must be run as normal user!"
		echo "Error: git-sync must be run as normal user!" >&2
		exit 2
	fi
}

show_help_message() {
	cat <<-EOF_XYZ
	Usage: git-sync [OPTION] [URI]...
	Easily synchronize cloned Git repositories on the local filesystem
	or forked repositories with upstream on the internet. By default the
	current directory is synchronized unless another directory path or
	option is provided.

	Options:
	 all - synchronize all repositories in configuration list
	 url - synchronize and merge upstream repository

	 version - show version information
	 help - show this help message

	Examples:
	 git-sync
	 git-sync --all
	 git-sync /path/to/repos/
	 git-sync --url git@example.com/project-repo.git
	 git-sync upstream https://example.com/project-repo.git

	Exit status:
	 0 - ok
	 1 - minor issue
	 2 - serious error

	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts

	See git(1) git-pull(1) git-fetch(1) git-push(1) and gittutorial(7) for
	additonal information and to provide insight how this wrapper works.
	EOF_XYZ
}

show_version_information() {
	cat <<-EOF_XYZ
	git-sync $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	git-sync: unrecognized option '$1'
	Try 'git-sync --help' for more information.
	EOF_XYZ
}

check_binary_exists() {
	local binary_command="$1"
	if [[ ! -x "$(which $binary_command)" ]]; then
		if [[ -x "/lib/command-not-found" ]]; then
			/lib/command-not-found "$binary_command"
		else
			cat <<-EOF_XYZ >&2
			Command '$binary_command' not found, but might be installed with:
			apt install "$binary_command"   # or
			dnf install "$binary_command"   # or
			opkg install "$binary_command"  # or
			snap install "$binary_command"  # or
			yum install "$binary_command"
			See your Linux documentation for which 'package manager' to use.
			EOF_XYZ
		fi
		exit 1
	fi
}

sync_directory() {
	if [[ -z "$1" ]]; then
		export orig_directory="$PWD"
		export sync_directory="$PWD"
	else
		export orig_directory="$PWD"
		export sync_directory="$1"
	fi

	ls -1 "$sync_directory" \
	| while read -r i; do
		if [[ ! "$orig_directory" == "$PWD" ]]; then
			cd "$orig_directory"
		fi

		if [[ -s "$i/.git/config" ]]; then
			cd "$i"
			echo "Synchronizing $(basename $i)..."
			git pull
			git fetch --all
			git push
			echo
		fi
	done

	if [[ ! "$orig_directory" == "$PWD" ]]; then
		cd "$orig_directory"
	fi

	unset orig_directory
	unset sync_directory
}

sync_config_list() {
	if [[ -s "/etc/git-sync.conf" ]]; then
		export git_sync_config="/etc/git-sync.conf"
	elif [[ -s "$HOME/.git-sync" ]]; then
		export git_sync_config="$HOME/.git-sync"
	else
		echo "Error: git-sync configuration is unavailable!" >&2
		exit 2
	fi

	grep -v -E '^#|^;|^ ' "$git_sync_config" \
	| while read -r f; do
		sync_directory "$f"
	done

	unset git_sync_config
}

sync_upstream() {
	if [[ -z "$1" ]]; then
		echo "Error: Must provide URL to upstream git repository!" >&2
		exit 2
	fi

	remote add upstream "$1"
	git remote
	git fetch upstream
	git checkout master
	git merge upstream/master
	git push origin master
}

check_binary_exists git

case "$1" in
all | --all)
	sync_config_list
	;;
url | --url)
	sync_upstream "$2"
	;;
version)
	show_version_information
	;;
help | --help)
	show_help_message
	;;
*)
	sync_directory "$1"
	;;
esac

exit 0

# vi: syntax=sh ts=2 noexpandtab
