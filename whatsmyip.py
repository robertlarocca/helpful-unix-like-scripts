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

SCRIPT_VERSION = str("1.0.6")
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
parser.add_argument("-a", "--all", help="all IPv4 and IPv6 addresses", action="store_true")
parser.add_argument("-4", "--ipv4", help="IPv4 address", action="store_true")
parser.add_argument("-6", "--ipv6", help="IPv6 address", action="store_true")
parser.add_argument("--hostname", help="reverse DNS lookup", action="store_true")
parser.add_argument("--network", help="service provider", action="store_true")
parser.add_argument("--location", help="physical location", action="store_true")
parser.add_argument("--timezone", help="timezone location", action="store_true")
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

    # Set the Internet Protocol (IP) version to use.
    # Options: 4, 6, or ("") an empty string for system default.
    # proto = str("")

    if os.name == "posix":
        i = os.popen(
            f"curl \
                -A {SCRIPT_NAME}/{SCRIPT_VERSION} \
                -f \
                -s{proto} \
                --connect-timeout 5 \
                {IP_SERVICE}/ip"
        ).read().rstrip()
    else:
        i = os.popen(
            f"curl.exe \
                -A {SCRIPT_NAME}/{SCRIPT_VERSION} \
                -f \
                -s{proto} \
                --connect-timeout 5 \
                {IP_SERVICE}/ip"
        ).read().rstrip()

    if i:
        if proto in ("4", "6"):
            print(f"IPv{proto}: {i}")
        else:
            print(f"IP: {i}")


def show_metadata(proto):
    """show_metadata"""

    # Set the Internet Protocol (IP) version to use.
    # Options: 4, 6, or ("") an empty string for system default.
    # proto = str("")

    if os.name == "posix":
        j = os.popen(
            f"curl \
                -A {SCRIPT_NAME}/{SCRIPT_VERSION} \
                -f \
                -s{proto} \
                --connect-timeout 5 \
                {IP_SERVICE}/json"
        ).read()
        try:
            m = json.loads(j)
        except:
            return
    else:
        j = os.popen(
            f"curl.exe \
                -A {SCRIPT_NAME}/{SCRIPT_VERSION} \
                -f \
                -s{proto} \
                --connect-timeout 5 \
                {IP_SERVICE}/json"
        ).read()
        try:
            m = json.loads(j)
        except:
            return

    # { "ip": "108.227.213.141",
    #   "ip_decimal": 1826870669,
    #   "country": "United States",
    #   "country_iso": "US",
    #   "country_eu": false,
    #   "region_name": "Florida",
    #   "region_code": "FL",
    #   "metro_code": 528,
    #   "zip_code": "33056",
    #   "city": "Miami Gardens",
    #   "latitude": 25.9409,
    #   "longitude": -80.2453,
    #   "time_zone": "America/New_York",
    #   "asn": "AS7018",
    #   "asn_org": "ATT-INTERNET4",
    #   "hostname": "108-227-213-141.lightspeed.miamfl.sbcglobal.net",
    #   "user_agent": {
    #     "product": "whatsmyip",
    #     "version": "0.0.1",
    #     "raw_value": "whatsmyip/0.0.1"
    #   }}

    if j and m:
        ip = str(m["ip"])
        ip_decimal = str(m["ip_decimal"])
        country = str(m["country"])
        country_iso = str(m["country_iso"]).upper()
        country_eu = str(m["country_eu"]).capitalize()
        region_name = str(m["region_name"])
        region_code = str(m["region_code"]).upper()
        zip_code = str(m["zip_code"]).upper()
        city = str(m["city"])
        latitude = str(m["latitude"])
        longitude = str(m["longitude"])
        time_zone = str(m["time_zone"])
        asn = str(m["asn"])
        asn_org = str(m["asn_org"])

        if proto in ("4", "6"):
            print(f"IPv{proto}: {ip}")
        else:
            print(f"IP: {ip}")

        if args.hostname:
            try:
                hostname = str(m["hostname"])
                print(f"Hostname: {hostname}")
            except:
                print(f"Hostname: None")

        if args.network:
            print(f"Network: {asn_org} ({asn})")

        if args.location:
            print(f"City: {city}")
            print(f"Region: {region_name}")
            print(f"Zip: {zip_code}")
            print(f"Country: {country}")
            print(f"EU: {country_eu}")

        if args.timezone:
            print(f"Time Zone: {time_zone}")

def whatsmyip():
    """main"""
    if args.version:
        show_version()

    if args.all:
        # show_ip("4")
        # show_ip("6")
        show_metadata("4")
        show_metadata("6")
    else:
        if args.ipv4:
            # show_ip("4")
            show_metadata("4")
        if args.ipv6:
            # show_ip("6")
            show_metadata("6")

    # Use the system default IP version.
    if not args.all and not args.ipv4 and not args.ipv6:
        show_metadata("")


if __name__ == "__main__":
    try:
        whatsmyip()
    except KeyboardInterrupt:
        pass

# vi: syntax=python ts=4 sw=4 sts=4 sr noet
