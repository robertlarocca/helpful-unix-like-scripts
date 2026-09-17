# Copyright (c) 2026 Robert LaRocca.

# Helpful aliases for busybox sysadmins, developers and the forgetful.

# Script version and release
SCRIPT_VERSION='4.3.1'
SCRIPT_RELEASE='release'  # options devel, beta, release, stable
export ALIASES_VERSION="$SCRIPT_VERSION-$SCRIPT_RELEASE"

# Set custom emoji prompt for user accounts.
PS1_ORIG="$PS1"
set_emoji_ps1_prompt() {
	if [[ -f "$HOME/.caffeinate" ]]; then
		# Emoji when caffeinate is enabled
		PS1="☕ $PS1_ORIG"
	elif [[ $USER = 'root' ]]; then
		PS1="🐳 $PS1_ORIG"
	elif [[ $USER = 'ansible' ]]; then
		PS1="🦄 $PS1_ORIG"
	elif [[ $USER = 'user1' ]]; then
		PS1="🫥 $PS1_ORIG"
	elif [[ $USER = 'user2' ]]; then
		PS1="🌀 $PS1_ORIG"
	elif [[ $USER = 'user3' ]]; then
		PS1="🥸 $PS1_ORIG"
	elif [[ $USER = 'user4' ]]; then
		PS1="🥁 $PS1_ORIG"
	elif [[ $USER = 'user5' ]]; then
		PS1="🛸 $PS1_ORIG"
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

# Include (source) the bash_private files also fix ownership and permission if available.
if [[ -f "$HOME/.bash_private" ]]; then
	chmod 0640 $HOME/.bash_private*
	chown $USER:$USER $HOME/.bash_private*
	source $HOME/.bash_private
fi

if [[ -f "$HOME/.bash_private_mysql" ]]; then
	source "$HOME/.bash_private_mysql"
fi

if [[ -f "$HOME/.bash_private_rabbit" ]]; then
	source "$HOME/.bash_private_rabbit"
fi

if [[ -f "$HOME/.bash_private_search" ]]; then
	source "$HOME/.bash_private_search"
fi

if [[ -f "$HOME/.bash_private_web" ]]; then
	source "$HOME/.bash_private_web"
fi

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
