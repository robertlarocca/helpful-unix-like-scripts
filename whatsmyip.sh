#!/bin/bash

# Copyright (c) 2023 Robert LaRocca http://www.laroccx.com

# Display the current ipv4 and ipv6 addresses

# Script version and release
script_version='2.0.0'
script_release='beta'  # options devel, beta, release, stable

require_root_privileges() {
	if [[ "$(whoami)" != "root" ]]; then
		# logger -i "Error: whatsmyip must be run as root!"
		echo "Error: whatsmyip must be run as root!" >&2
		exit 2
	fi
}

show_help_message() {
	cat <<-EOF_XYZ
	No help message yet...
	EOF_XYZ
}

show_version_information() {
	cat <<-EOF_XYZ
	whatsmyip $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts-aliases
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	whatsmyip: unrecognized option '$1'
	Try 'whatsmyip --help' for more information.
	EOF_XYZ
}

flag_emoji() {
	# Flag emoji may be used for the country_code:
	# https://apps.timwhitlock.info/emoji/tables/iso3166

	local country_code="$(curl -s https://ifconfig.io/country_code)"

	case "$country_code" in
	CA)
		flag="🏳️"
		;;
	US)
		flag="⛳"
		;;
	MX)
		flag="🏴"
		;;
	*)
		flag="👻"
		;;
	esac

	if [[ -n "$flag" ]]; then
		echo "Flag: $flag"
	fi
}

ipv4_address() {
	local ipv4="$(curl -s4 https://ifconfig.co/ip)"

	if [[ -n "$ipv4" ]]; then
		echo "IPv4: $ipv4"
	fi
}

ipv6_address() {
	local ipv6="$(curl -s6 https://ifconfig.co/ip)"

	if [[ -n "$ipv6" ]]; then
		echo "IPv6: $ipv6"
	fi
}

# Options
case "$1" in
all)
	ipv4_address
	ipv6_address
	flag_emoji
	;;
-4)
	ipv4_address
	;;
-6)
	ipv6_address
	;;
flag)
	flag_emoji
	;;
version)
	show_version_information
	;;
help | --help)
	show_help_message
	;;
*)
	if [[ -z "$1" ]]; then
		ipv4_address
		ipv6_address
	else
		error_unrecognized_option "$1"
		exit 1
	fi
	;;
esac

# vi: syntax=sh ts=2 noexpandtab
