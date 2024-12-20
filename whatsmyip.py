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

SCRIPT_VERSION = str("1.0.5")
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
parser.add_argument("-4", "--ipv4", help="IPv4 address", action="store_true")
parser.add_argument("-6", "--ipv6", help="IPv6 address", action="store_true")
parser.add_argument("--all", help="all metadata", action="store_true")
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
    print("Copyright (c) 2024 Robert LaRocca, https://www.laroccx.com")
    print("License: The MIT License (MIT)")
    print("Source: https://github.com/robertlarocca/helpful-unix-like-scripts")
    sys.exit(0)


def show_ip(proto):
    """show_ip"""
    if os.name == "posix":
        i = os.popen(
            f"curl -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s{proto} --connect-timeout 3 --retry 2 {IP_SERVICE}/ip"
        ).read().rstrip()
    else:
        i = os.popen(
            f"curl.exe -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s{proto} --connect-timeout 3 --retry 2 {IP_SERVICE}/ip"
        ).read().rstrip()

    if i is not None:
        if proto in ("4", "6"):
            print(f"IP: {i}")
        else:
            print(f"IP: {i}")
        show_metadata(proto)


def show_metadata(proto):
    """show_metadata"""
    if os.name == "posix":
        j = os.popen(
            f"curl -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s{proto} --connect-timeout 3 --retry 2 {IP_SERVICE}/json"
        ).read()
        m = json.loads(j)
    else:
        j = os.popen(
            f"curl.exe -A {SCRIPT_NAME}/{SCRIPT_VERSION} -s{proto} --connect-timeout 3 --retry 2 {IP_SERVICE}/json"
        ).read()
        m = json.loads(j)

    if j and m is not None:
        if args.all:
            print("Country: " + m["country"])
            print("ISO: " + m["country_iso"])
            print("Region: " + m["region_name"])
            print("City: " + m["city"])
            print("ZIP: " + m["zip_code"])
            print("TZ: " + m["time_zone"])
            print("ASN: " + m["asn"])
            print("ISP: " + m["asn_org"])
        if args.country:
            print("Country: " + m["country"])
        if args.iso:
            print("ISO: " + m["country_iso"])
        if args.region:
            print("Region: " + m["region_name"])
        if args.city:
            print("City: " + m["city"])
        if args.zip:
            print("ZIP: " + m["zip_code"])
        if args.timezone:
            print("TZ: " + m["time_zone"])
        if args.asn:
            print("ASN: " + m["asn"])
        if args.isp:
            print("ISP: " + m["asn_org"])
        if args.json:
            print(j)


def main():
    """main"""
    if args.version:
        show_version()
    if args.ipv4:
        show_ip("4")
    elif args.ipv6:
        show_ip("6")
    else:
        show_ip("4")
        show_ip("6")


if __name__ == "__main__":
    main()
    sys.exit(0)

# vi: syntax=python ts=4 noexpandtab
