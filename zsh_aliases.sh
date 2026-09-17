# Copyright (c) 2026 Robert LaRocca.

# Helpful aliases for zsh sysadmins, developers and the forgetful.

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

# User options for zsh_aliases to show aliases, commands, help and version.
zsh_aliases() {
	show_help() {
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
		 lvmsnapshot - show example commands to create lvm snapshots
		 mkpsk - generate a secure random 64 character pre-shared key
		 mkpw - generate a secure ambiguous random 14 character password
		 mksecret - generate a secure random 512 character LUKS secret
		 test-port - check network port and try to connect with telnet
		 security-headers - check website availability and display headers

		Options:
		 --version - show version information
		 --help - show this help message

		Exit Status:
		 0 - ok
		 1 - minor issue
		 2 - serious error

		Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/hhelpful-unix-like-scripts

		See bash(1) csh(1) dash(1) zsh(1) man(1) nologin(8) and os-release(5)
		for additional information and for insights into how this script works.
		EOF_XYZ
	}

	show_version_information() {
		cat <<-EOF_XYZ
		zsh_aliases $SCRIPT_VERSION-$SCRIPT_RELEASE
		Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/hhelpful-unix-like-scripts
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
		show_help
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
	if [[ -x "$(which smbpasswd 2> /dev/null)" ]]; then
		smbpasswd -U "$domain_realm/$domain_user" -r "$domain_controller"
		# Display reminder after changed password.
		smbpasswd_status="$?"
		if [[ "$smbpasswd_status" == 0 ]]; then
			echo "Reminder: Lock workstation to begin using changed password" 2>&1
		fi
	else
		if [[ -x "/usr/lib/command-not-found" ]]; then
			/usr/lib/command-not-found "smbpasswd"
		elif [[ "$(uname -s)" == "Darwin" ]] && [[ -x "$(which kpasswd 2> /dev/null)" ]]; then
			cat <<-EOF_XYZ 2>&1
			Command 'smbpasswd' not available, but 'kpasswd' could work on macOS:
			kpasswd "$domain_user@$domain_realm"
			EOF_XYZ
		fi
	fi
}

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

# Prevent conflicts with existing kubectl installs.
alias kubectl="microk8s kubectl"

# Enable Bitwarden ssh-agent support for use with OpenSSH commands.
# export SSH_AUTH_SOCK="/Users/$USER/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock" # App Store
# export SSH_AUTH_SOCK=/home/$USER/snap/bitwarden/current/.bitwarden-ssh-agent.sock # Snap
# export SSH_AUTH_SOCK=/home/$USER/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock # Flatpak

# Prevent pubkey authentication with OpenSSH commands.
alias scp-passwd="scp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias sftp-passwd="sftp -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias ssh-passwd="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

# Show example commands how-to create logical volume (lvm) snapshots.
lvmsnapshot() {
	cat <<-EOF_XYZ
	Examples to create logical volume snapshots using the 'lvcreate' command:
	 lvcreate --size 25%ORIGIN --snapshot --name snap1 /dev/ubuntu/root
	 lvcreate --size 50%ORIGIN --snapshot --name snap2 /dev/ubuntu/mysql
	 lvcreate -L 32G -s -n snap3 /dev/ubuntu/www
	 lvcreate -L 8G -s -n snap4 /dev/ubuntu/home

	See lvcreate(8) and lvremove(8) manual pages for additional information.
	EOF_XYZ
}

# Generate a single secure random pre-shared key.
mkpsk() {
	case "$1" in
	wrap | --wrap | -w)
		psk=$(head -c 64 /dev/urandom | base64)
		;;
	long | --long | -l | *)
		# Default
		psk=$(head -c 64 /dev/urandom | base64 --wrap=0)
		;;
	esac

	echo "$psk"
	unset psk
}

# Generate a single secure random password.
mkpw() {
	if [[ -x "$(which pwgen 2> /dev/null)" ]]; then
		pw=$(pwgen --capitalize --numerals --symbols --ambiguous 20 1)
	else
		if [[ -x "/usr/lib/command-not-found" ]]; then
		/usr/lib/command-not-found "pwgen"
		elif [[ "$(uname -s)" == "Darwin" ]]; then
		cat <<-EOF_XYZ 2>&1
		Command 'pwgen' not found, but can be installed on macOS with:
		 brew install pwgen  <or>
		 port install pwgen

		Remember: You must use the package manager installed on your operating system!
		EOF_XYZ
		else
		cat <<-EOF_XYZ 2>&1
		Command 'pwgen' not found, but can be installed with:
		 apt install pwgen      <or>
		 dnf install pwgen      <or>
		 flatpak install pwgen  <or>
		 snap install pwgen     <or>
		 yum install pwgen      <or>
		 zypper install pwgen

		Remember: You must use the package manager for your operating system!
		EOF_XYZ
		fi
	fi

	echo "$pw"
	unset pw
}

# Generate a single secure random LUKS device secret.
mksecret() {
	case "$1" in
	long | --long | -l)
		secret=$(head -c 512 /dev/urandom | base64 --wrap=0)
		;;
	wrap | --wrap | -w | *)
		# Default
		secret=$(head -c 512 /dev/urandom | base64)
		;;
	esac

	echo "$secret"
	unset secret
}

# Check website availability and display security headers.
security-headers() {
	local website_url="$1"
	if [[ -n "$website_url" ]]; then
		echo "$website_url"
		curl -A "security-headers/$SCRIPT_VERSION-$SCRIPT_RELEASE" -ISs --connect-timeout 5 --retry 1 "$website_url"
	else
		for website_url in \
			https://duckduckgo.com \
			https://ubuntu.com \
			https://www.apple.com \
			https://www.google.com \
			https://www.laroccx.com \
			https://www.microsoft.com ; do
			echo "$website_url"
			curl curl -A "security-headers/$SCRIPT_VERSION-$SCRIPT_RELEASE" -ISs --connect-timeout 5 --retry 1 "$website_url"
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
	if [[ -x "$(which telnet 2> /dev/null)" ]]; then
		case "$1" in
		--port | -p)
			telnet $server_address "$2"
			;;
		*)
			if [[ -z "$1" ]]; then
				telnet $server_address $service_port
			else
				cat <<-EOF_XYZ
				test-port: unrecognized option '$*'
				Try 'test-port --port <port_number>' to check a specific port.
				EOF_XYZ
			fi
			;;
		esac
	else
		if [[ -x "/usr/lib/command-not-found" ]]; then
			/usr/lib/command-not-found "telnet"
		elif [[ "$(uname -s)" == "Darwin" ]] && [[ -x "$(which port 2> /dev/null)" ]]; then
			cat <<-EOF_XYZ 2>&1
			Command 'telnet' not found, but can be installed with:
			sudo port install inetutils
			EOF_XYZ
		fi
	fi
}

# Ookla speedtest-cli alias to display minimal output by default.
alias speedtest="speedtest-cli --simple"

# Install required and helpful software packages used by this repository.
install-hhelpful-unix-like-scripts-packages() {
	if [[ -x "$(which apt 2> /dev/null)" ]]; then
		sudo apt autoclean
		sudo apt update
		sudo apt --yes install byobu dnsutils git htop iperf3 nmap pwgen samba-common-bin speedtest-cli telnet tree whois
	elif [[ -x "$(which dnf 2> /dev/null)" ]]; then
		sudo dnf clean all
		sudo dnf --assumeyes install dnsutils git htop iperf3 nmap pwgen samba-common-bin speedtest-cli telnet tree whois
	elif [[ -x "$(which yum 2> /dev/null)" ]]; then
		sudo yum clean all
		sudo yum --assumeyes install dnsutils git htop iperf3 nmap pwgen samba-common-bin speedtest-cli telnet tree whois
	elif [[ "$(uname -s)" == "Darwin" ]] && [[ -x "$(which port 2> /dev/null)" ]]; then
		xcode-select --install
		sudo port -q -R selfupdate
		sudo port -q -R upgrade outdated
		sudo port -q -c install byobu htop iperf3 nmap pwgen speedtest-cli tree
	fi
}

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
