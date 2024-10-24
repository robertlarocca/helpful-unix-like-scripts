#!/usr/bin/env bash

# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Synchronize all Git repositories in the current directory or the list of directories.

# Script version and release
script_version='4.1.0'
script_release='devel'  # options devel, beta, release, stable

# Uncomment to enable bash xtrace mode.
# set -xv

require_root_privileges() {
	if [[ "$(id -un)" != "root" ]]; then
		# logger -i "Error: git-sync must be run as root!"
		echo "Error: git-sync must be run as root!" >&2
		exit 2
	fi
}

require_user_privileges() {
	if [[ "$(id -un)" == "root" ]]; then
		# logger -i "Error: git-sync must be run as normal user!"
		echo "Error: git-sync must be run as normal user!" >&2
		exit 2
	fi
}

show_help() {
	cat <<-EOF_XYZ
	Usage: git-sync [OPTION] <URI>...
	Easily synchronize cloned Git repositories on the local filesystem
	or forked repositories with upstream on the internet. By default the
	current directory is synchronized unless another option is provided.

	When a empty .gitsync-ignore file exists in the repository directory,
	it will prevent git-sync from syncing even if the repository path is
	saved in the ~/.gitsync or /etc/gitsync configuration files.

	Options:
	 --all       Synchronize all repositories in configuration file
	 --repo      Synchronize all repositories in provided path
	 --upstream  Synchronize and merge upstream repository

	 --version   Display version information
	 --help      Display this help message

	Examples:
	 git-sync
	 git-sync /path/to/repo/
	 git-sync /path/to/repos/
	 git-sync --repo /path/to/repo/
	 git-sync --repo /path/to/repos/
	 git-sync --all
	 git-sync --upstream git@example.com/project-repo.git
	 git-sync --upstream https://example.com/project-repo.git

	Exit status:
	 0 - ok
	 1 - minor issue
	 2 - serious error

	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-shell-scripts

	See git(1) git-pull(1) git-fetch(1) git-push(1) and gittutorial(7) for
	additonal information and to provide insight how this wrapper works.
	EOF_XYZ
	exit 0
}

show_version() {
	cat <<-EOF_XYZ
	git-sync $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-unix-like-shell-scripts
	EOF_XYZ
	exit 0
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	git-sync: unrecognized option '$1'
	Try 'git-sync --help' for more information.
	EOF_XYZ
	exit 1
}

check_binary_exists() {
	local binary_command="$1"
	if [[ ! -x "$(which $binary_command 2> /dev/null)" ]]; then
		if [[ -x "/lib/command-not-found" ]]; then
			/lib/command-not-found "$binary_command"
		else
			cat <<-EOF_XYZ >&2
			Command '$binary_command' not found, but might be installed with:
			apt install "$binary_command"   # or
			dnf install "$binary_command"   # or
			opkg install "$binary_command"  # or
			snap install "$binary_command"  # or
			xcode-select --install

			See your Unix-like operating system documentation for which 'package manager' to use.
			EOF_XYZ
		fi
		exit 1
	fi
}

sync_ignore() {
	echo "Ignoring $(basename $PWD)..."
}

git_pull_fetch_push_clone() {
	echo "Synchronizing $(basename $PWD)..."
	git pull
	git fetch --all --tags
	git push
}

git_add_fetch_merge_upstream() {
	remote add upstream "$1"
	git remote
	git fetch upstream
	git checkout master
	git merge upstream/master
	git push origin master
}

sync_directory() {
	if [[ -z "$1" ]]; then
		export orig_path="$PWD"
		export sync_path="$PWD"
		if [[ -s "$orig_path/.git/config" ]]; then
			if [[ -f "$orig_path/.gitsync-ignore" ]]; then
				sync_ignore
				return
			else
				git_pull_fetch_push_clone
				return
			fi
		else
			exit 1
		fi
	else
		if [[ -d "$1" ]]; then
			export orig_path="$PWD"
			export sync_path="$(realpath $1 2> /dev/null)"
			if [[ -s "$sync_path/.git/config" ]]; then
				if [[ -f "$sync_path/.gitsync-ignore" ]]; then
					cd "$sync_path"
					sync_ignore
					cd "$orig_path"
					return
				else
					cd "$sync_path"
					git_pull_fetch_push_clone
					cd "$orig_path"
					return
				fi
			fi
		else
			echo "git-sync: $1: No such file or directory" >&2
			exit 1
		fi
	fi

	for i in $(ls -1 "$sync_path" 2> /dev/null); do
		if [[ ! "$PWD" -ef "$orig_path" ]]; then
			cd "$orig_path"
		fi

		if [[ -s "$sync_path/$i/.git/config" ]]; then
			if [[ -f "$sync_path/$i/.gitsync-ignore" ]]; then
				cd "$sync_path/$i"
				sync_ignore
			else
				cd "$sync_path/$i"
				git_pull_fetch_push_clone
			fi
		fi
	done

	if [[ ! "$PWD" -ef "$orig_path" ]]; then
		cd "$orig_path"
	fi

	unset orig_path
	unset sync_path
}

sync_list() {
	if [[ -s "/etc/gitsync" ]]; then
		export conf_path="/etc/gitsync"
	elif [[ -s "$HOME/.gitsync" ]]; then
		export conf_path="$HOME/.gitsync"
	else
		echo "git-sync: No configuration file" >&2
		exit 2
	fi

	grep -v -E '^#|^;|^ ' "$conf_path" | while read -r line; do
		sync_directory "$line"
	done

	unset conf_path
}

sync_upstream() {
	if [[ -z "$1" ]]; then
		echo "git-sync: No upstream repository URL" >&2
		exit 1
	else
		git_add_fetch_merge_upstream "$1"
	fi
}

check_binary_exists git

case "$1" in
--all)
	sync_list
	;;
--repo | --repos)
	sync_directory "$2"
	;;
--upstream)
	sync_upstream "$2"
	;;
--version)
	show_version
	;;
--help)
	show_help
	;;
*)
	sync_directory "$1"
	;;
esac

exit 0

# vi: syntax=sh ts=4 noexpandtab
