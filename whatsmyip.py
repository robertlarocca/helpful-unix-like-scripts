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

SCRIPT_VERSION = str("1.0.2")
SCRIPT_RELEASE = str("beta")  # Options: devel, beta, release, stable

# Set the IP lookup webservice URL.
IP_SERVICE = str("https://ifconfig.co")

# ----- Required global variables ----- #

parser = argparse.ArgumentParser(
    prog="whatsmyip",
    description="Display the current public IP addresses and geolocation metadata.",
    add_help=True
)
parser.add_argument("-v", "--version", help="show version and exit", action="store_true")
parser.add_argument("-a", "--all", help="IPv4 and IPv6 addresses", action="store_true")
parser.add_argument("-4", "--ipv4", help="IPv4 address", action="store_true")
parser.add_argument("-6", "--ipv6", help="IPv6 address", action="store_true")
parser.add_argument("--country", help="country name", action="store_true")
parser.add_argument("--iso", help="country ISO code", action="store_true")
parser.add_argument("--region", help="region (aka state) name", action="store_true")
parser.add_argument("--city", help="city name", action="store_true")
parser.add_argument("--zip", help="ZIP (aka postal) code", action="store_true")
parser.add_argument("--timezone", help="timezone name", action="store_true")
parser.add_argument("--asn", help="ASN code", action="store_true")
parser.add_argument("--isp", help="ISP name", action="store_true")
parser.add_argument("--json", help="all metadata as json", action="store_true")
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

    if inet4:
        if args.ipv4 or args.all:
            print("IPv4: " + inet4)
    if inet6:
        if args.ipv6 or args.all:
            print("IPv6: " + inet6)


def show_metadata():
    """show_metadata"""
    inet = os.popen(
        f"curl -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s {IP_SERVICE}/json"
    ).read()
    metadata = json.loads(inet)

    if inet and metadata:
        if args.country:
            print("Country: " + metadata["country"])
        if args.iso:
            print("ISO: " + metadata["country_iso"])
        if args.region:
            print("Region: " + metadata["region_name"])
        if args.city:
            print("City: " + metadata["city"])
        if args.zip:
            print("ZIP: " + metadata["zip_code"])
        if args.timezone:
            print("TZ: " + metadata["time_zone"])
        if args.asn:
            print("ASN: " + metadata["asn"])
        if args.isp:
            print("ISP: " + metadata["asn_org"])
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
