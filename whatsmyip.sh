#!/bin/bash

# Copyright (c) 2023 Robert LaRocca http://www.laroccx.com

# Display the current ipv4 and ipv6 addresses

# Script version and release
script_version='2.1.0'
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
	Usage: whatsmyip [OPTION]...
	Display the current public IP addresses and host geolocation information.

	This script is not affiliated with ifconfig.co or Leafcloud. They are a
	great free option for looking up IP information. Please limit automated
	requests to 1 request per minute. No guarantee is made for requests that
	exceed this limit. You may be rate-limited with a 429 status code, or
	dropped entirely.

	You can run your own IP lookup service. The source code and documentation
	are available on GitHub https://github.com/leafcloudhq/echoip

	Options:
	 all - display all public IP addresses and host information.
	 -4 - display only the public IPv4 address.
	 -6 - display only the public IPv6 address.
	 flag - display the geo location country flag.

	 version - show version information
	 help - show this help message

	Exit status:
	 0 - ok
	 1 - minor issue
	 2 - serious error

	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts
	EOF_XYZ
}

show_version_information() {
	cat <<-EOF_XYZ
	whatsmyip $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/helpful-linux-bash-scripts
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	whatsmyip: unrecognized option '$1'
	Try 'whatsmyip --help' for more information.
	EOF_XYZ
}

json_details() {
	local json="$(curl -s https://ifconfig.co/json)"

	if [[ -n "$json" ]]; then
		echo "$json"
		echo
	fi
}

flag_emoji() {
	# Flag emoji might not display properly depending on the terminal being used.
	#
	# Checkout all the emoji country flag options:
	#   https://apps.timwhitlock.info/emoji/tables/iso3166

	local country_iso="$(curl -s https://ifconfig.co/country-iso)"

	case "$country_iso" in
	CA)
		flag="🥞"
		;;
	US)
		flag="🍔"
		;;
	MX)
		flag="🌯"
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
4 | -4)
	ipv4_address
	;;
6 | -6)
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
