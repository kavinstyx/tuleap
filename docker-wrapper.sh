#!/bin/bash

set -e

function create-data-dirs {
    mkdir -p /data/etc/tuleap /data/etc/ssh /data/home \
             /data/var/lib/tuleap /data/var/lib/gitolite \
             /data/var/lib/mailman /data/var/lib/mysql /data/root
}

function move-data-dirs {
    [[ -d /etc/tuleap ]] && mv /etc/tuleap /data/etc/
    [[ -d /etc/ssh ]] && mv /etc/ssh /data/etc/
    [[ -d /home ]] && mv /home /data/
    [[ -d /var/lib/tuleap ]] && mv /var/lib/tuleap /data/var/lib/
    [[ -d /var/lib/gitolite ]] && mv /var/lib/gitolite /data/var/lib/
    [[ -d /var/lib/mailman ]] && mv /var/lib/mailman /data/var/lib/
    [[ -d /var/lib/mysql ]] && mv /var/lib/mysql /data/var/lib/
    [[ -d /root ]] && mv /root /data/ && chmod 700 /data/root
}

function create-data-symlinks {
    ln -sf /data/etc/tuleap /etc/tuleap
    ln -sf /data/etc/ssh /etc/ssh
    ln -sf /data/home /home
    ln -sf /data/var/lib/tuleap /var/lib/tuleap
    ln -sf /data/var/lib/gitolite /var/lib/gitolite
    ln -sf /data/var/lib/mailman /var/lib/mailman
    ln -sf /data/var/lib/mysql /var/lib/mysql
    ln -sf /data/root /root
}

# Initial Tuleap configuration
if [[ ! -e /etc/tuleap/conf/local.inc ]]; then
    echo "Running Tuleap setup..."
    /usr/share/tuleap-install/setup.sh --disable-domain-name-check \
        --sys-default-domain="${DEFAULT_DOMAIN}" \
        --sys-org-name="${ORG_NAME}" \
        --sys-long-org-name="${ORG_NAME}"

    # Stop services if running (kill instead of systemctl)
    pkill httpd || true
    pkill mariadbd || true

    if [[ ! -e /data/etc/tuleap/conf/local.inc ]]; then
        create-data-dirs
        move-data-dirs
    fi

    create-data-symlinks

    # Run Tuleap database migrations
    /usr/lib/forgeupgrade/bin/forgeupgrade --config=/etc/tuleap/forgeupgrade/config.ini update
fi

# Start PHP FPM (Remi path)
/opt/remi/php82/root/usr/sbin/php-fpm &

# Start MariaDB (non-systemd)
/usr/libexec/mariadbd --basedir=/usr &

# Start Mailman
/usr/lib/mailman/bin/mailmanctl start

# Start rsyslog and cron
rsyslogd
crond

# Start Apache in foreground
/usr/sbin/httpd -DFOREGROUND
