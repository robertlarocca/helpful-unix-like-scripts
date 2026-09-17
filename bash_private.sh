# Copyright (c) 2026 Robert LaRocca.

# Helpful ash, bash, zsh aliases for the private and forgetful.

# SCRIPT_VERSION='2.4.0'
# SCRIPT_RELEASE='release'  # options devel, beta, release, stable

# Use nano as default text editor with ansible-vault.
alias ansible-vault-nano="EDITOR=nano $(which ansible-vault)"

# Execute dep (aka deployer) command installed to root filesystem or custom repository directory
if [[ -x "$(which dep)" ]]; then
	alias dep="$(which dep)"
	alias deployer="dep"
else
	alias dep="$PWD/dep/vendor/bin/dep"
	alias deployer="dep"
fi

iperf3-server() {
	# local iperf3_server="server.example.com"
	local iperf3_server="$1"
	local iperf3_port="5201"
	$(which iperf3) --verbose --version4 --client $iperf3_server --port $iperf3_port
}

rdiff() {
	local host1="$1"
	local host2="$2"
	local file_path="$3"
	local diff_cmd_options="$4"

	if [[ -n "$3" ]]; then
		diff --color=always --side-by-side $diff_cmd_options <(ssh $host1 "cat $file_path") <(ssh $host2 "cat $file_path")
	else
		cat <<-EOF_XYZ
		rdiff: unrecognized option '$*'
		Try 'rdiff <hostname1> <hostname2> "/path/to/remote/file"' for example.
		EOF_XYZ

		return 1
	fi
}

rdiffx() {
	local host1="$1"
	local host2="$2"
	local execute_command="$3"
	local diff_cmd_options="$4"

	if [[ -n "$3" ]]; then
		diff --color=always --side-by-side $diff_cmd_options <(ssh $host1 "$execute_command") <(ssh $host2 "$execute_command")
	else
		cat <<-EOF_XYZ
		rdiffx: unrecognized option '$*'
		Try 'rdiffx <hostname1> <hostname2> "remote-command"' for example.
		EOF_XYZ
		return 1
	fi
}

crowdstrike-falcon-sensor() {
	local release_tag="v1.12.2"
	local ssh_hostname="$1"
	local user_options="$2"

	# Validate the remote hostname and user options are provided
	if [ -z "$ssh_hostname" ]; then
		echo "Error: You must provide the <hostname> of remote device!" >&2
		break 1
	elif [ -z "$user_options" ]; then
		echo "Warning: You must provide an option [--install or --uninstall] to execute!" >&2
		break 1
	fi

	# Include (source) the falcon.cnf file also fix ownership and permissions if available.
	if [ -f "$HOME/.crowdstrike/falcon.cnf" ]; then
		# The single user configuration file
		chmod 0640 "$HOME/.crowdstrike/falcon.cnf"
		chmod 0750 "$HOME/.crowdstrike"
		chown -R $USER:$USER "$HOME/.crowdstrike"
		source "$HOME/.crowdstrike/falcon.cnf"
	elif [ -f "/etc/crowdstrike/falcon.cnf" ]; then
		# The system-wide configuration file that multiple users can access
		chmod 0640 "/etc/crowdstrike/falcon.cnf"
		chmod 0750 "/etc/crowdstrike"
		chown -R root:adm "/etc/crowdstrike"
		source "/etc/crowdstrike/falcon.cnf"
	fi

	# user options
	case "$2" in
	--install | -i)
		ssh "$ssh_hostname" "
			export FALCON_CLIENT_ID=${FALCON_CLIENT_ID}
			export FALCON_CLIENT_SECRET=${FALCON_CLIENT_SECRET}
			export FALCON_CLOUD=${FALCON_CLOUD}
			export FALCON_CID=${FALCON_CID}
			export FALCON_SENSOR_VERSION_DECREMENT=${FALCON_SENSOR_VERSION_DECREMENT}
			export FALCON_DOWNLOAD_PATH=${FALCON_DOWNLOAD_PATH}
			export ALLOW_LEGACY_CURL=${ALLOW_LEGACY_CURL}
			curl -L https://raw.githubusercontent.com/crowdstrike/falcon-scripts/${release_tag}/bash/install/falcon-linux-install.sh | bash
			"
		;;
	--uninstall | -u | --remove | -r)
		ssh "$ssh_hostname" "
			export FALCON_CLIENT_ID=${FALCON_CLIENT_ID}
			export FALCON_CLIENT_SECRET=${FALCON_CLIENT_SECRET}
			export FALCON_CLOUD=${FALCON_CLOUD}
			export FALCON_CID=${FALCON_CID}
			export FALCON_SENSOR_VERSION_DECREMENT=${FALCON_SENSOR_VERSION_DECREMENT}
			export FALCON_DOWNLOAD_PATH=${FALCON_DOWNLOAD_PATH}
			export ALLOW_LEGACY_CURL=${ALLOW_LEGACY_CURL}
			curl -L https://raw.githubusercontent.com/crowdstrike/falcon-scripts/${release_tag}/bash/install/falcon-linux-ininstall.sh | bash
			"
		;;
	*)
		# Default
		cat <<-EOF_XYZ
		crowdstrike-falcon-sensor: unrecognized option '$@'

		The following examples should get you started:
		  crowdstrike-falcon-sensor <user@hostname> --install    # or
		  crowdstrike-falcon-sensor <user@hostname> --uninstall

		Try 'crowdstrike-falcon-sensor --help' for more information.
		EOF_XYZ
		break 1
	esac
}

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
