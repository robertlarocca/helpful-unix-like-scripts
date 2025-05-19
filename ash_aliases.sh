# Copyright (c) Robert LaRocca, http://www.laroccx.com

# Helpful aliases for busybox sysadmins, developers and the forgetful.

# Script version and release
script_version='4.1.4'
script_release='release'  # options devel, beta, release, stable
export ALIASES_VERSION="$script_version-$script_release"

# Set custom emoji prompt for user accounts.
PS1_ORIG="$PS1"
set_emoji_ps1_prompt() {
	if [[ -f "$HOME/.caffeinate" ]]; then
		# Emoji when caffeinate is enabled
		PS1="☕ $PS1_ORIG"
	elif [[ $USER = 'root' ]]; then
		PS1="🧀 $PS1_ORIG"
	elif [[ $USER = 'user1' ]]; then
		PS1="🦄 $PS1_ORIG"
	elif [[ $USER = 'user2' ]]; then
		PS1="🐡 $PS1_ORIG"
	elif [[ $USER = 'user3' ]]; then
		PS1="🏓 $PS1_ORIG"
	fi
}
set_emoji_ps1_prompt

# Set custom PATH for ash (BusyBox) shell.
PATH="$PATH:/usr/local/sbin:/usr/local/bin"

# Exit or purge the current shell session history with clean command.
clean() {
	# The which command unfortunately does not work here.
	# We must use the absolute filesystem path to clean binary.
	/usr/local/bin/clean "$@"
	local clean_status="$?"

	if [[ "$SHELL" == "/bin/ash" ]]; then
		echo "Warning: Cannot purge ash (BusyBox) history buffer." 2>&1
	fi

	if [[ "$clean_status" -ge "4" ]]; then
		history -c 2> /dev/null
		history -p 2> /dev/null
	fi

	if [[ "$clean_status" -ge "5" ]]; then
		exit 2> /dev/null
	fi
}

alias swupdate="$(which swupdate) --opkg"

# Include bash_private if available.
if [[ -f "$HOME/.ash_private" ]]; then
	source $HOME/.ash_private
fi

# vi: syntax=sh ts=4 sw=4 sts=4 sr noet
