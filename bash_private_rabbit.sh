# Copyright (c) 2026 Robert LaRocca.

# Helpful rabbitmq aliases for the private and forgetful.

# SCRIPT_VERSION='2.4.0'
# SCRIPT_RELEASE='release'  # options devel, beta, release, stable

rabbit-helper() {
	case "$1" in
	--help | -h)
		cat <<-EOF_XYZ
		No built-in help or manual page yet. The help message goes here...
		EOF_XYZ
		;;
	--version | -v)
		cat <<-EOF_XYZ
		rabbit-helper (RabbitMQ Helper) v${SCRIPT_VERSION}-${SCRIPT_RELEASE}
		Copyright (c) 2024-2026 Robert LaRocca.
		License: The MIT License (MIT)
		Source: https://github.com/robertlarocca/helpful-unix-like-scripts
		EOF_XYZ
		;;
	*)
		# Default
		if [ -z "$1" ]; then
			echo "Default command"
		else
			cat <<-EOF_XYZ
			rabbit-helper: unrecognized option '$*'
			Try 'rabbit-helper --help'
			Try 'rabbit-helper --version'
			EOF_XYZ
		fi
		;;
	esac
}

alias rabbitmq-helper="rabbit-helper"

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
