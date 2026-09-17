# Helpful Magento, Magerun2 Wordpress, and Composer aliases for the forgetful.

# SCRIPT_VERSION='2.5.1'
# SCRIPT_RELEASE='release'  # options devel, beta, release, stable

# Set the Magento site and shared directories
# MAGENTO_WEBSITE_DIR="/var/www/deploy/current"
# MAGENTO_WEBSITE_DIR="/var/www/magento"
# MAGENTO_SHARED_DIR="/var/www/deploy/shared"
# MAGENTO_SHARED_DIR="/var/www/magento/shared"
MAGENTO_WEBSITE_DIR="$PWD"
MAGENTO_SHARED_DIR="$PWD/shared"

# Set the Wordpress site and shared directories
# WORDPRESS_WEBSITE_DIR="/var/www/deploy/current"
# WORDPRESS_WEBSITE_DIR="/var/www/wordpress"
# WORDPRESS_SHARED_DIR="/var/www/deploy/shared"
# WORDPRESS_SHARED_DIR="/var/www/wordpress/shared"
WORDPRESS_WEBSITE_DIR="$PWD"
WORDPRESS_SHARED_DIR="$PWD/shared"

# Execute composer as the required www-data user and site directory
# alias composer="sudo -u www-data $(command -v composer) --working-dir=$MAGENTO_WEBSITE_DIR --no-cache"
alias composer="$(command -v composer) --working-dir=$PWD --no-cache"

# Execute magento command as the required www-data user and site directory
# alias magento="sudo -u www-data $(command -v php) $MAGENTO_WEBSITE_DIR/bin/magento"
alias magento="$(command -v php) $MAGENTO_WEBSITE_DIR/bin/magento"

# Execute magerun2 command as the required www-data user and site directory
# alias magerun2="sudo -u www-data $(command -v magerun2) --root-dir=$MAGENTO_WEBSITE_DIR"
alias magerun2="$(command -v magerun2) --root-dir=$MAGENTO_WEBSITE_DIR"

# Execute wp (aka wordpress) command as the required www-data user and site directory
alias wordpress="wp"
alias wp="sudo -u www-data $(command -v wp) --path=$WORDPRESS_WEBSITE_DIR"


# Edit or display the magento crontab as the required www-data user
# Usage:
# magento-helper --crontab <edit, install, list>
# magento-helper --maintenance <enable, disable>
# magento-helper --setup <all, cache, compile, static>
# magento-helper --reindex
# magento-helper --reset
# magento-helper --encryption
# magento-helper --help
# magento-helper --version

magento-helper() {
	case "$1" in
	--help | -h)
		echo "Help message goes here..."
		;;
	--version | -v)
		echo "Version information goes here..."
		;;
	--crontab)
		case "$2" in
		edit)
			sudo $(command -v crontab) -u www-data -e
			;;
		install)
			magento cron:install
			;;
		list | show)
			sudo $(command -v crontab) -u www-data -l
			;;
		*)
			cat <<-EOF_XYZ
			magento-helper: unrecognized option '$*'
			Try 'magento-helper --crontab edit' to edit cron schedule.
			Try 'magento-helper --crontab install' to add magento to cron schedule.
			Try 'magento-helper --crontab list' to display current cron schedule.
			EOF_XYZ
			;;
		esac
		;;
	--maintenance)
		case "$2" in
		enable)
			magento maintenance:enable
			;;
		disable)
			magento maintenance:disable
			;;
		*)
			cat <<-EOF_XYZ
			magento-helper: unrecognized option '$*'
			Try 'magento-helper --maintenance enable' to enable mode.
			Try 'magento-helper --maintenance disable' to disable mode.
			EOF_XYZ
			;;
		esac
		;;
	--setup)
		case "$2" in
		all)
			magento maintenance:enable \
				&& magento cache:clean \
				&& magento cache:enable full_page \
				&& magento setup:upgrade --keep-generated \
				&& magento setup:di:compile \
				&& magento setup:static-content:deploy --force \
				&& magento cache:flush \
				&& magento maintenance:disable
			;;
		cache)
			magento maintenance:enable \
				&& magento cache:clean \
				&& magento cache:enable full_page \
				&& magento setup:upgrade --keep-generated \
				&& magento cache:flush \
				&& magento maintenance:disable
			;;
		compile)
			magento maintenance:enable \
				&& magento cache:clean \
				&& magento setup:upgrade --keep-generated \
				&& magento setup:di:compile \
				&& magento cache:flush \
				&& magento maintenance:disable
			;;
		static)
			magento maintenance:enable \
				&& magento cache:clean \
				&& magento setup:upgrade --keep-generated \
				&& magento setup:static-content:deploy --force \
				&& magento cache:flush \
				&& magento maintenance:disable
			;;
		*)
			if [[ -z "$2" ]]; then
				magento maintenance:enable \
					&& magento setup:upgrade --keep-generated \
					&& magento maintenance:disable
			else
				cat <<-EOF_XYZ
				magento-helper: unrecognized option '$*'
				Try 'magento-helper --setup' to setup upgrade.
				Try 'magento-helper --setup all' to setup upgrade with all options.
				Try 'magento-helper --setup cache' to setup upgrade and enable full-page cache.
				Try 'magento-helper --setup compile' to setup upgrade and compile.
				Try 'magento-helper --setup static' to setup upgrade and deploy static content.
				EOF_XYZ
			fi
			;;
		esac
		;;
	--reindex)
		magento indexer:reset \
			&& magento indexer:reindex
		;;
	--reset)
		# Remove temporary files and rebuild or compile the Magento website
		# including either the OpenSearch or Elasticsearch indexes
		magento maintenance:enable

		sudo systemctl stop nginx.service php8.3-fpm.service varnish.service

		# sudo rm -rfv $MAGENTO_SHARED_DIR/var
		# sudo rm -rfv $MAGENTO_SHARED_DIR/var/*
		# sudo rm -fv $MAGENTO_SHARED_DIR/var/.maintenance.ip

		sudo rm -fv $MAGENTO_SHARED_DIR/var/.regenerate.lock
		sudo rm -fv $MAGENTO_SHARED_DIR/var/.setup_cronjob_status
		sudo rm -fv $MAGENTO_SHARED_DIR/var/.update_cronjob_status
		sudo rm -fv $MAGENTO_SHARED_DIR/var/varnish.vcl

		sudo rm -rfv $MAGENTO_SHARED_DIR/generated/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/backups
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/cache/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/composer_home
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/export/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/import_export/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/import_history/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/import/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/importexport/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/log/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/logging/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/page_cache/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/report/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/session/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/tmp/*
		sudo rm -rfv $MAGENTO_SHARED_DIR/var/view_preprocessed/*

		sudo rm -rfv $MAGENTO_WEBSITE_DIR/generated
		sudo rm -rfv $MAGENTO_WEBSITE_DIR/var/cache
		sudo rm -rfv $MAGENTO_WEBSITE_DIR/var/page_cache
		sudo rm -rfv $MAGENTO_WEBSITE_DIR/var/view_preprocessed

		sudo systemctl start varnish.service php8.3-fpm.service nginx.service

		magento cache:clean \
			&& magento cache:enable full_page \
			&& magento setup:upgrade --keep-generated \
			&& magento setup:di:compile \
			&& magento setup:static-content:deploy --force \
			&& magento indexer:reset \
			&& magento encryption:key:change \
			&& magento encryption:data:re-encrypt \
			&& magento encryption:payment-data:update \
			&& magento cache:flush

		curl -A "magento-helper" -s https://adm1.example.com/opcache-reset/ 2> /dev/null && echo
		curl -A "magento-helper" -s https://web1.example.com/opcache-reset/ 2> /dev/null && echo
		curl -A "magento-helper" -s https://web2.example.com/opcache-reset/ 2> /dev/null && echo
		curl -A "magento-helper" -s https://web3.example.com/opcache-reset/ 2> /dev/null && echo
		curl -A "magento-helper" -s https://web4.example.com/opcache-reset/ 2> /dev/null && echo
		curl -A "magento-helper" -s https://web5.example.com/opcache-reset/ 2> /dev/null && echo

		curl -A "magento-helper" -X 'PURGE' -H 'X-Magento-Tags-Pattern: .*' -s https://adm1.example.com:6081 2> /dev/null && echo
		curl -A "magento-helper" -X 'PURGE' -H 'X-Magento-Tags-Pattern: .*' -s https://web1.example.com:6081 2> /dev/null && echo
		curl -A "magento-helper" -X 'PURGE' -H 'X-Magento-Tags-Pattern: .*' -s https://web2.example.com:6081 2> /dev/null && echo
		curl -A "magento-helper" -X 'PURGE' -H 'X-Magento-Tags-Pattern: .*' -s https://web3.example.com:6081 2> /dev/null && echo
		curl -A "magento-helper" -X 'PURGE' -H 'X-Magento-Tags-Pattern: .*' -s https://web4.example.com:6081 2> /dev/null && echo
		curl -A "magento-helper" -X 'PURGE' -H 'X-Magento-Tags-Pattern: .*' -s https://web5.example.com:6081 2> /dev/null && echo

		magento maintenance:disable \
			&& magento indexer:reindex
		;;
	--encryption)
			sudo cp -v $MAGENTO_SHARED_DIR/app/etc/env.php $MAGENTO_SHARED_DIR/app/etc/env.php-bak
			sudo chmod 0640 $MAGENTO_SHARED_DIR/app/etc/env.php* 2> /dev/null
			sudo chown root:root $MAGENTO_SHARED_DIR/app/etc/env.php-bak* $MAGENTO_SHARED_DIR/app/etc/env.php-orig* 2> /dev/null

			sudo cp -v $MAGENTO_WEBSITE_DIR/app/etc/config.php $MAGENTO_WEBSITE_DIR/app/etc/config.php-bak
			sudo chmod 0640 $MAGENTO_WEBSITE_DIR/app/etc/config.php* 2> /dev/null
			sudo chown root:root $MAGENTO_WEBSITE_DIR/app/etc/config.php-bak* $MAGENTO_WEBSITE_DIR/app/etc/config.php-orig* 2> /dev/null

			magento maintenance:enable \
				&& magento cache:clean \
				&& magento encryption:key:change \
				&& magento encryption:data:re-encrypt \
				&& magento encryption:payment-data:update \
				&& magento cache:flush \

			magento maintenance:disable \
				&& magento encryption:data:list-re-encryptors \
		;;
	*)
		# Default
		if [[ -z "$1" ]]; then
			magento app:config:status
		else
			cat <<-EOF_XYZ
			magento-helper: unrecognized option '$*'
			Try 'magento-helper --help'
			Try 'magento-helper --version'
			Try 'magento-helper --maintenance'
			EOF_XYZ
		fi
		;;
	esac
}

# Display the average memory usage for PHP-FPM processes
php-fpm-memusage() {
	PHP_CMD=php-fpm
	AVG_MEM=$(ps -C $PHP_CMD -o rss= | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024," MiB") }')
	echo "Usage: $AVG_MEM average per process"
}

# code: language=sh
# vi: syntax=sh ts=4 sw=4 sts=4 noexpandtab
# vim: set filetype=sh ts=4 sw=4 sts=4 noexpandtab
