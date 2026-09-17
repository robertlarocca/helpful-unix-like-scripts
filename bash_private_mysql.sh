# Copyright (c) 2026 Robert LaRocca.

# Helpful mysql and mariadb aliases for the forgetful.

# SCRIPT_VERSION='2.4.0'
# SCRIPT_RELEASE='release'  # options devel, beta, release, stable

# Set the default user for MySQL related commands
MYSQL_USER="$HOME/.mysql/$USER.cnf"

# Always execute mysql and related commands using root login
alias mysql="$(which mysql) --defaults-extra-file=$MYSQL_USER"
alias mysqladmin="$(which mysqladmin) --defaults-extra-file=$MYSQL_USER"
alias mysqlanalyze="$(which mysqlanalyze) --defaults-extra-file=$MYSQL_USER"
alias mysqlcheck="$(which mysqlcheck) --defaults-extra-file=$MYSQL_USER"
alias mysqldump="$(which mysqldump) --defaults-extra-file=$MYSQL_USER"
alias mysqloptimize="$(which mysqloptimize) --defaults-extra-file=$MYSQL_USER"
alias mysqlrepair="$(which mysqlrepair) --defaults-extra-file=$MYSQL_USER"
alias mysql_secure_installation="$(which mysql_secure_installation) --defaults-extra-file=$MYSQL_USER"
alias mysqlshow="$(which mysqlshow) --defaults-extra-file=$MYSQL_USER"
alias mysqltuner="$(which mysqltuner) --defaults-extra-file=$MYSQL_USER"
alias xtrabackup="$(which xtrabackup) --defaults-extra-file=$MYSQL_USER"


# Create the custom Percona MySQL functions
mysql-install-components() {
	mysql -e "INSTALL COMPONENT 'file://component_percona_udf';"
}

# MySQL flush privileges (twice)
mysql-flush-privileges() {
	mysql -e "FLUSH PRIVILEGES; FLUSH PRIVILEGES;"
}

# Install the Percona MySQL Audit Log plugin
# NOTE: This provides extra monitoring and logging of user connections and query activity.
mysql-install-plugins() {
	mysql -e "INSTALL PLUGIN audit_log SONAME 'audit_log.so';"
}

# Purge all the MySQL binary logs
# REMINDER: Never execute this function (aka command) on cluster and replication servers.
mysql-purge-binlogs() {
	mysql -e "FLUSH BINARY LOGS; PURGE BINARY LOGS BEFORE NOW(); PURGE BINARY LOGS BEFORE NOW();"
}

# Reset the MySQL binary logs
# REMINDER: Never execute this function (aka command) on cluster and replication servers.
mysql-reset-binlogs() {
	mysql -e "FLUSH BINARY LOGS; RESET BINARY LOGS AND GTIDS;"
}

# Show helpful information about the local MySQL user accounts
mysql-show-users() {
	mysql -e "FLUSH PRIVILEGES; SELECT user as User, host as Host, account_locked as 'Locked (Status)', plugin as 'Password (Type)' FROM mysql.user;"
}

# Display help and version information or execute related binaries with the mysql-helper command.
mysql-helper() {
	case "$1" in
	--help | -h)
		cat <<-EOF_XYZ
		Sorry, no built-in help or manual page yet.
		The mysql-helper command help and version information goes here...
		EOF_XYZ
		;;
	--version | -v)
		cat <<-EOF_XYZ
		mysql-helper (MySQL and MariaDB Helper) v${SCRIPT_VERSION}-${SCRIPT_RELEASE}
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
			mysql-helper: unrecognized option '$*'
			Try 'mysql-helper --help'
			Try 'mysql-helper --version'
			EOF_XYZ
		fi
		;;
	esac
}

alias mariadb-helper="mysql-helper"

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
