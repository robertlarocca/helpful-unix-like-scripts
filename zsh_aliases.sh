# Copyright (c) 2024 Robert LaRocca http://www.laroccx.com

# Helpful zsh_aliases for sysadmins, developers and the forgetful.

# Script version and release
script_version='4.0.0'
script_release='devel'  # options devel, beta, release, stable
export ZSH_ALIASES_VERSION="$script_version-$script_release"

# Set custom emoji prompt for user accounts.
PS1_ORIG="$PS1"
set_emoji_ps1_prompt() {
	if [[ -f "$HOME/.caffeinate" ]]; then
		# Emoji when caffeinate is enabled
		PS1="☕ $PS1_ORIG"
	elif [[ $USER = 'root' ]]; then
		# Emoji for root
		PS1="🧀 $PS1_ORIG"
	elif [[ $USER = 'user1' ]]; then
		# Emoji for user1
		PS1="🦄 $PS1_ORIG"
	elif [[ $USER = 'user2' ]]; then
		# Emoji for user2
		PS1="🩻 $PS1_ORIG"
	elif [[ $USER = 'user3' ]]; then
		# Emoji for user3
		PS1="🧟 $PS1_ORIG"
	fi
}
set_emoji_ps1_prompt

# User options for zsh_aliases to show aliases, commands, help and version.
zsh_aliases() {
	show_help_message() {
		cat <<-EOF_XYZ
		Usage: zsh_aliases | <alias> | <command> [OPTION] [PARAMETER]...
		Helpful zsh_aliases for sysadmins, developers and the forgetful.

		This zsh_aliases script by default (without an option) will only return
		the text 'OK'. The commands section displays aliases and functions that
		may be executed without the zsh_aliases prefix, just like any other
		installed Unix-like program or builtin utilities. This zsh_aliases file
		has only ever been tested with Ubuntu and Ubuntu under WSL2.

		Aliases:
		 kubectl - alias to prevent microk8s conflicts with existing (kubectl) packages
		 scp-passwd -  alias to prevent secure copy (scp) pubkey authentication
		 sftp-passwd - alias to prevent secure file transfer (sftp) pubkey authentication
		 ssh-passwd - alias to prevent secure remote login (ssh) pubkey authentication
		 speedtest - alias for Ookla (speedtest-cli) command with minimal output

		Commands:
		 adpasswd - change your Active Directory domain user password
		 mkpsk - generate a secure random 64 character pre-shared key
		 mkpw - generate a secure ambiguous random 14 character password
		 mksecret - generate a secure random 512 character LUKS secret
		 test-port - check network port and try to connect with telnet
		 test-website - check website availability and display headers

		Options:
		 --version - show version information
		 --help - show this help message

		Exit Status:
		 0 - ok
		 1 - minor issue
		 2 - serious error

		Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/helpful-linux-macos-shell-scripts

		See bash(1) csh(1) dash(1) zsh(1) man(1) nologin(8) and os-release(5)
		for additional information and for insights into how this script works.
		EOF_XYZ
	}

	show_version_information() {
		cat <<-EOF_XYZ
		zsh_aliases $script_version-$script_release
		Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/helpful-linux-macos-shell-scripts
		EOF_XYZ
	}

	error_unrecognized_option() {
		cat <<-EOF_XYZ
		zsh_aliases: unrecognized option '$1'
		Try 'zsh_aliases --help' for more information.
		EOF_XYZ
	}

	case "$1" in
	--version)
		show_version_information
		;;
	--help)
		show_help_message
		;;
	*)
		# Default
		if [[ -z "$2" ]]; then
			echo "OK"
			return 0
		else
			error_unrecognized_option "$*"
			return 1
		fi
		;;
	esac
}

# Change your Active Directory domain user password.
adpasswd() {
	# Set the realm and domain name.
	local domain_realm="EXAMPLE"
	local domain_name="example.com"

	# Set the default domain controller IP address or hostname. Leaving as
	# the $domain_name variable often provides the best available connection.
	# local domain_controller="192.168.99.21"
	local domain_controller="$domain_name"

	# Use the current username when specific username not provided.
	if [[ -z "$1" ]]; then
		# Set to the Active Directory username if different
		# from the Linux username variable.
		local domain_user="$USER"
	else
		# Use the specific username provided.
		local domain_user="$1"
	fi

	# The samba-common-bin (aka smbpasswd) packaged must be installed.
	if [[ -x "$(which smbpasswd)" ]]; then
		smbpasswd -U "$domain_realm"/"$domain_user" -r "$domain_controller"

		# Display reminder after changed password.
		smbpasswd_status="$?"
		if [[ "$smbpasswd_status" == 0 ]]; then
			echo "Reminder: Lock workstation to begin using changed password" 2>&1
		fi
	else
		if [[ -x "/usr/lib/command-not-found" ]]; then
			/usr/lib/command-not-found "smbpasswd"
		elif [[ "$(uname -s)" == "Darwin" ]] && [[ -x "$(which kpasswd)" ]]; then
			echo "Command 'smbpasswd' not available, but 'kpasswd' on macOS should also work." 2>&1
		fi
	fi
}

# Purge the current shell session history after
# removing files using the clean command.
clean() {
	# Must use absolute path to the clean script.
	# Unfortunately the which command wont work.
	/usr/local/bin/clean "$@"
	if [[ "$SHELL" == "/bin/bash" ]]; then
		history -c
	elif [[ "$SHELL" == "/bin/zsh" ]]; then
		history -p
	fi
}

# Prevent conflicts with existing kubectl installs.
alias kubectl="microk8s kubectl"

# Prevent pubkey authentication with OpenSSH related commands.
alias scp-passwd="scp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias sftp-passwd="sftp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias ssh-passwd="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

# Generate a secure random password.
mkpw() {
	if [[ -x "$(which pwgen)" ]]; then
		pwgen --capitalize --numerals --symbols --ambiguous 14 1
	else
		if [[ -x "/usr/lib/command-not-found" ]]; then
			/usr/lib/command-not-found "pwgen"
		elif [[ "$(uname -s)" == "Darwin" ]] && [[ -x "$(which port)" ]]; then
			echo "Command 'pwgen' not found, but can be installed with:" 2>&1
			echo "sudo port install pwgen" 2>&1
		fi
	fi
}

# Generate a secure random pre-shared key.
mkpsk() {
	head -c 64 /dev/urandom | base64
}

# Generate a secure random LUKS device secret.
mksecret() {
	head -c 512 /dev/urandom | base64
}

# Check website availability and display headers.
test-website() {
	local website_url="$1"
	if [[ -n "$website_url" ]]; then
		echo "$website_url"
		curl -A "website-tester/$script_version-$script_release" -ISs --connect-timeout 5 --retry 1 "$website_url"
	else
		for website_url in \
			https://duckduckgo.com \
			https://ubuntu.com \
			https://www.apple.com \
			https://www.google.com \
			https://www.laroccx.com \
			https://www.microsoft.com ; do
			echo "$website_url"
			curl curl -A "website-tester/$script_version-$script_release" -ISs --connect-timeout 5 --retry 1 "$website_url"
			echo
		done
	fi
}

# Test firewall ports using the telnet command.
# alias test-port-43210="test-port --port 43210"
test-port() {
	# The server address and service port are tested by default.
	local server_address='telnet.example.com'
	local service_port='8738'
	if [[ -x "$(which telnet)" ]]; then
		case "$1" in
		--port | -p)
			telnet $server_address "$2"
			;;
		*)
			if [[ -z "$1" ]]; then
				telnet $server_address $service_port
			else
				cat <<-EOF_XYZ
				test_port: unrecognized option '$*'
				Try 'test-port --port <port_number>' to check a specific port.
				EOF_XYZ
			fi
			;;
		esac
	else
		if [[ -x "/usr/lib/command-not-found" ]]; then
			/usr/lib/command-not-found "telnet"
		elif [[ "$(uname -s)" == "Darwin" ]] && [[ -x "$(which port)" ]]; then
			echo "Command 'telnet' not found, but can be installed with many extras:" 2>&1
			echo "sudo port install inetutils" 2>&1
		fi
	fi
}

# Ookla speedtest-cli alias to display minimal output by default.
alias speedtest="speedtest-cli --simple"

# Install required and helpful apt packages used by this repository.
install-helpful-linux-shell-scripts-apt-packages() {
	sudo apt autoclean
	sudo apt update
	sudo apt --yes install byobu dnsutils git htop nmap pwgen samba-common-bin speedtest-cli tasksel telnet tree whois
}

# Install required and helpful dnf packages used by this repository.
# For legacy OS versions modify dnf to yum, otherwise just update.
install-helpful-linux-shell-scripts-dnf-packages() {
	sudo dnf clean all
	sudo dnf check-update
	sudo dnf --assumeyes install dnsutils git nmap pwgen samba-common-bin speedtest-cli telnet tree whois
}

# Install required helpful macOS and port packages used by this repository.
install-helpful-macos-shell-scripts-cli-packages() {
	xcode-select --install
	sudo port -q -R selfupdate
	sudo port -q -R upgrade outdated
	sudo port -q -c install byobu htop nmap pwgen speedtest-cli tree
}

# Include zsh_private if available.
if [[ -f "$HOME/.zsh_private" ]]; then
	source "$HOME/.zsh_private"
fi

# vi: syntax=sh ts=2 noexpandtab
