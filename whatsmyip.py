#!/usr/bin/python3
# -*- coding=utf-8 -*-

# Copyright (c) 2024 Robert LaRocca <https://www.laroccx.com>

# This source code is governed by a MIT-style license that can be found
# in the included LICENSE file. If not, see <https://mit-license.org/>.

import argparse
import json
import os
import sys


# ----- Required global variables ----- #

SCRIPT_FILE = os.path.basename(__file__)
SCRIPT_NAME = str("whatsmyip")

SCRIPT_VERSION = str("1.0.1")
SCRIPT_RELEASE = str("beta")  # Options: devel, beta, release, stable

# Set the default IP protocol version and webservice URL.
IP_PROTOCOL = str("")
IP_SERVICE = str("https://ifconfig.co")

# ----- Required global variables ----- #

parser = argparse.ArgumentParser(
    prog="whatsmyip",
    description="Display the current public IP addresses and geolocation metadata.",
    add_help=True
)
parser.add_argument("-v", "--version", help="show version and exit", action="store_true")
parser.add_argument("-a", "--all", help="use IPv4 and IPv6 protocols", action="store_true")
parser.add_argument("-4", "--ipv4", help="use IPv4 protocol", action="store_true")
parser.add_argument("-6", "--ipv6", help="use IPv6 protocol", action="store_true")
parser.add_argument("--json", help="show geolocation metadata as json", action="store_true")
args = parser.parse_args()


def show_version():
    """show_version"""
    print(f"{SCRIPT_NAME} ({SCRIPT_FILE}) v{SCRIPT_VERSION}-{SCRIPT_RELEASE}")
    sys.exit(0)


def show_ips():
    """show_ip"""
    inet4 = os.popen(
        f"curl -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s4 {IP_SERVICE}/ip"
    ).read().rstrip()

    inet6 = os.popen(
        f"curl -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s6 {IP_SERVICE}/ip"
    ).read().rstrip()

    if args.ipv4 or args.all and inet4:
        print("IPv4: " + inet4)
    if args.ipv6 or args.all and inet6:
        print("IPv6: " + inet6)


def show_metadata():
    """show_metadata"""
    inet = os.popen(
        f"curl -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s {IP_SERVICE}/json"
    ).read()
    metadata = json.loads(inet)

    if inet and metadata:
        if args.json:
            print(inet)


def main():
    """main"""
    if args.version:
        show_version()
    else:
        show_ips()
        show_metadata()


if __name__ == "__main__":
    main()
    sys.exit(0)

# vi: syntax=python ts=4 noexpandtab
