#!/usr/bin/env python3
# -*- coding=utf-8 -*-

# Copyright (c) 2024 Robert LaRocca <https://www.laroccx.com>

# This source code is governed by a MIT-style license that can be found
# in the included LICENSE file. If not, see <https://mit-license.org/>.

import argparse
import glob
import os
import platform
import shutil
import signal
import sys

# ----- Required global variables ----- #

file_name = os.path.basename(__file__)
user_home = os.path.expanduser("~")

# ----- Required global variables ----- #

parser = argparse.ArgumentParser("clean")
parser.add_argument("-a", "--all", help="remove all history files", action="store_true")
parser.add_argument("-m", "--most", help="remove most history files (default)", action="store_true")
parser.add_argument("-c", "--clear", help="clear screen", action="store_true")
parser.add_argument("-e", "--exit", help="exit shell", action="store_true")
parser.add_argument("-r", "--reboot", help="reboot system", action="store_true")
parser.add_argument("-s", "--shutdown", help="shutdown system", action="store_true")
parser.add_argument("-z", "--sleep", help="and sleep system", action="store_true")
args = parser.parse_args()

def require_root_privileges():
    if os.name == "posix":
        if os.geteuid() != 0:
            print("Error: " + file_name + " must be run as root!")
            exit(2)

def show_help():
    help_message = "usage: clean [-ameW] [-rsz] time warning-message]"
    print(help_message)
    exit(0)

def show_version():
    script_version = "1.0.0"
    script_release = "devel" # options devel, beta, release, stable
    print(file_name, script_version + "-" + script_release)
    exit(0)

def remove_history():
    if os.name == "posix":
        shutil.rmtree(os.path.join(user_home, ".bash_sessions"), ignore_errors=True)
        shutil.rmtree(os.path.join(user_home, ".zsh_sessions"), ignore_errors=True)

        try:
            os.remove(os.path.join(user_home, ".bash_history"))
            os.remove(os.path.join(user_home, ".mysql_history"))
            os.remove(os.path.join(user_home, ".psql_history"))
            os.remove(os.path.join(user_home, ".python_history"))
            os.remove(os.path.join(user_home, ".rediscli_history"))
            os.remove(os.path.join(user_home, ".zsh_history"))
        except:
            pass
    else:
        try:
            os.remove(os.path.join(user_home, "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"))
        except:
            pass

    clear_history()

    if args.clear:
        clear_screen()

    if args.exit:
        exit_shell()
    elif args.reboot:
        reboot_host()
    elif args.shutdown:
        shutdown_host()
    elif args.sleep:
        sleep_host()

def remove_history_all():
    if os.name == "posix":
        shutil.rmtree(os.path.join(user_home, ".ansible"), ignore_errors=True)
        shutil.rmtree(os.path.join(user_home, ".bash_sessions"), ignore_errors=True)
        shutil.rmtree(os.path.join(user_home, ".cache"), ignore_errors=True)
        shutil.rmtree(os.path.join(user_home, ".zsh_sessions"), ignore_errors=True)

        try:
            os.remove(os.path.join(user_home, ".bash_history"))
            os.remove(os.path.join(user_home, ".lesshst"))
            os.remove(os.path.join(user_home, ".local/share/nano/search_history"))
            os.remove(os.path.join(user_home, ".motd_shown"))
            os.remove(os.path.join(user_home, ".mysql_history"))
            os.remove(os.path.join(user_home, ".psql_history"))
            os.remove(os.path.join(user_home, ".python_history"))
            os.remove(os.path.join(user_home, ".rediscli_history"))
            os.remove(os.path.join(user_home, ".selected_editor"))
            os.remove(os.path.join(user_home, ".ssh/known_hosts.old"))
            os.remove(os.path.join(user_home, ".ssh/known_hosts"))
            os.remove(os.path.join(user_home, ".sudo_as_admin_successful"))
            os.remove(os.path.join(user_home, ".viminfo"))
            os.remove(os.path.join(user_home, ".wget-hsts"))
            os.remove(os.path.join(user_home, ".zsh_history"))
        except:
            pass
    else:
        try:
            os.remove(os.path.join(user_home, "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"))
            os.remove(os.path.join(user_home, "AppData\Roaming\Microsoft\Windows\Recent", glob.glob("*.lnk", recursive=False)))
            os.remove(os.path.join(user_home, "AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations", glob.glob("*", recursive=False)))
            os.remove(os.path.join(user_home, "AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations", glob.glob("*", recursive=False)))
        except:
            pass

    clear_history()

    if args.clear:
        clear_screen()

    if args.exit:
        exit_shell()
    elif args.reboot:
        reboot_host()
    elif args.shutdown:
        shutdown_host()
    elif args.sleep:
        sleep_host()

def clear_history():
    if os.name == "posix":
        try:
            os.system("history -p")
        except:
            os.system("history -c")

def clear_screen():
    if os.name == "posix":
        os.system("clear")
    else:
        os.system("cls")

def reboot_host():
    if os.name == "posix":
        try:
            os.system("sudo shutdown -r +0")
        except:
            os.system("shutdown.exe /r /t 0")

def shutdown_host():
    if os.name == "posix":
        try:
            os.system("sudo shutdown -h +0")
        except:
            os.system("shutdown.exe /s /t 0")

def sleep_host():
    if os.name == "posix":
        try:
            os.system("sudo shutdown -s +0")
        except:
            os.system("shutdown.exe /h /t 0")

def exit_shell():
    # os.system("exit")
    # os.exit("0")
    ps = os.system("ps -f")
    pid = os.getpid()
    pgid = os.getpgid(pid)

    print(ps, "\n")
    print("PID", pid, "\n")
    print("PPID", pgid), "\n"

def main():
    if args.all:
        remove_history_all()
    else:
        remove_history()

if __name__ == "__main__":
    main()

exit(0)

# vi: syntax=python ts=4 noexpandtab
