# Copyright (c) 2026 Robert LaRocca.

# Helpful opensearch or elasticsearch aliases for the private and forgetful.

# SCRIPT_VERSION='2.4.1'
# SCRIPT_RELEASE='release'  # options devel, beta, release, stable

# Include (source) the OpenSearch server.cnf file also fix ownership and permissions if available.
if [ -f "$HOME/.opensearch/server.cnf" ]; then
	# The single user configuration file
	chmod 0640 "$HOME/.opensearch/server.cnf"
	chmod 0750 "$HOME/.opensearch"
	chown -R $USER:$USER "$HOME/.opensearch"
	source "$HOME/.opensearch/server.cnf"
elif [ -f "/etc/opensearch/server.cnf" ]; then
	# The system-wide configuration file that multiple users can access
	chmod 0640 "/etc/opensearch/server.cnf"
	chmod 0750 "/etc/opensearch"
	chown -R root:adm "/etc/opensearch"
	source "/etc/opensearch/server.cnf"
fi

# OpenSearch check command with user option support
# --health display cluster health status (default option)
# --version display node version
opensearch-check() {
	case "$1" in
	--health | health)
		curl -X GET "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/_cluster/health?pretty" \
			-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD"
		;;
	--version | version)
		curl -X GET "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/?pretty" \
			-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD"
		;;
	*)
		# Default
		if [[ -z "$1" ]]; then
			echo "# Health"
			curl -X GET "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/_cluster/health?pretty" \
				-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD"

			echo "# Version"
			curl -X GET "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/?pretty" \
				-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD"
		else
			cat <<-EOF_XYZ
			opensearch-check: unrecognized option '$*'
			Try 'opensearch-check --health' to show cluster health status.
			Use 'opensearch-check --version' to show node version.
			EOF_XYZ
		fi
		;;
	esac
}

# Delete OpenSearch index(es) using globing and regex pattern.
#
# Examples:
#  - opensearch-delete-index <index-name>
#  - opensearch-delete-index magento2*
#  - opensearch-delete-index *
opensearch-delete-index() {
	curl -X DELETE "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/$1?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD"
}

# Show OpenSearch index(es) information and settings using globing or regex pattern.
#
# Examples:
#  - opensearch-show-index-settings <index-name>
#  - opensearch-show-index-settings magento2*
#  - opensearch-show-index-settings *
opensearch-show-index-settings() {
	curl -X GET "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/$1/_settings?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD"
}

# Configure OpenSearch number of replicas per index on single node cluster.
#
# NOTE: This may change the status from yellow to green with the correct settings.
#
# Examples:
#  - opensearch-index-replicas <index_name> <number_of_replicas>
#  - opensearch-index-replicas magento2* 0
#  - opensearch-index-replicas security-auditlog* 0
#  - opensearch-index-replicas top_queries* 0
opensearch-index-replicas() {
	# Configure security-auditlog and top_queries index templates.
	curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/_template/security-auditlog-1?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
		-H "content-type: application/json" \
		-d "{\"index_patterns\":[\"security-auditlog-*\"],\"settings\":{\"number_of_replicas\":0}}"

	curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/_template/top_queries-1?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
		-H "content-type: application/json" \
		-d "{\"index_patterns\":[\"top_queries-*\"],\"settings\":{\"number_of_replicas\":0}}"

	# Configure custom index name using globing or regex pattern.
	if [[ -n "$1" ]]; then
		if [[ -n "$2" ]]; then
			curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/$1/_settings?pretty" \
				-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
				-H "content-type: application/json" \
				-d "{\"index\":{\"number_of_replicas\":$2}}"
		else
			curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/$1/_settings?pretty" \
				-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
				-H "content-type: application/json" \
				-d "{\"index\":{\"number_of_replicas\":0}}"
		fi
	fi

	# Configure popular index names with default 0 (zero) number of replicas.
	curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/magento2*/_settings?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
		-H "content-type: application/json" \
		-d "{\"index\":{\"number_of_replicas\":0}}" 2> /dev/null

	curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/security-auditlog*/_settings?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
		-H "content-type: application/json" \
		-d "{\"index\":{\"number_of_replicas\":0}}"

	curl -X PUT "https://$OPENSEARCH_FQDN:$OPENSEARCH_PORT/top_queries*/_settings?pretty" \
		-k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
		-H "content-type: application/json" \
		-d "{\"index\":{\"number_of_replicas\":0}}"
}

# Show enabled OpenSearch plugins and install, remove, or update extra analysis plugins.
#
# Examples:
#  - opensearch-plugins <option>
#  - opensearch-plugins --list    (default)
#  - opensearch-plugins --install
#  - opensearch-plugins --remove
#  - opensearch-plugins --upgrade
opensearch-plugins() {
	case "$1" in
	--list | list)
		echo "REMINDER: The extra analysis plugins might not be required on this platform."
		/usr/share/opensearch/bin/opensearch-plugin --silent list
		;;
	--install | install)
		sudo /usr/share/opensearch/bin/opensearch-plugin --silent install analysis-icu
		sudo /usr/share/opensearch/bin/opensearch-plugin --silent install analysis-phonetic
		;;
	--remove | remove)
		sudo /usr/share/opensearch/bin/opensearch-plugin --silent remove analysis-icu
		sudo /usr/share/opensearch/bin/opensearch-plugin --silent remove analysis-phonetic
		;;
	--upgrade | upgrade)
		sudo /usr/share/opensearch/bin/opensearch-plugin --silent list \
			| grep --ignore-case --regexp="^analysis" \
			| while read -r plugin; do
				sudo /usr/share/opensearch/bin/opensearch-plugin --silent remove "$plugin"
				sudo /usr/share/opensearch/bin/opensearch-plugin --silent install "$plugin"
			done
		;;
	*)
		# Default
		if [[ -z "$1" ]]; then
			echo "REMINDER: The extra analysis plugins might not be required on this platform."
			sudo /usr/share/opensearch/bin/opensearch-plugin --silent list
		else
			cat <<-EOF_XYZ
			opensearch-plugins: unrecognized option '$*'
			Try 'opensearch-plugins --list' show all enabled plugins.
			Use 'opensearch-plugins --install' install extra analysis plugins.
			Use 'opensearch-plugins --remove' remove extra analysis plugins.
			Use 'opensearch-plugins --upgrade' upgrade extra analysis plugins.
			EOF_XYZ
		fi
		;;
	esac
}

# Display help and version information or execute related binaries with the opensearch-helper command.
opensearch-helper() {
	case "$1" in
	--help | -h)
		cat <<-EOF_XYZ
		Sorry, no built-in help or manual page yet.
		The opensearch-helper command help and version information goes here...
		EOF_XYZ
		;;
	--version | -v)
		cat <<-EOF_XYZ
		opensearch-helper (OpenSearch and Elasticearch Helper) v${SCRIPT_VERSION}-${SCRIPT_RELEASE}
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
			opensearch-helper: unrecognized option '$*'
			Try 'opensearch-helper --help'
			Try 'opensearch-helper --version'
			EOF_XYZ
		fi
		;;
	esac
}

alias elasticsearch-helper="opensearch-helper"

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
