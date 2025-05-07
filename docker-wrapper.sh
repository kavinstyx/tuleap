#!/bin/bash

set -e

echo " Starting Tuleap container initialization..."

# Create persistent data directories
function create-data-dirs {
    mkdir -p /data/etc/tuleap /data/etc/ssh /data/home \
             /data/var/lib/tuleap /data/var/lib/gitolite \
             /data/var/lib/mailman /data/var/lib/mysql /data/root
}

# Move initial data into /data volume
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

# Create symbolic links to the data volume
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

# First-time volume setup
if [[ ! -e /data/etc/tuleap/conf/local.inc ]]; then
    echo " First time setup: initializing /data volume..."
    create-data-dirs
    move-data-dirs
    create-data-symlinks
else
    echo " Existing Tuleap configuration found."
    create-data-symlinks
fi

# Start PHP FPM (Remi SCL path)
/opt/remi/php82/root/usr/sbin/php-fpm &
echo " PHP-FPM started."

# Start MariaDB (non-systemd)
/usr/libexec/mariadbd --basedir=/usr --datadir=/var/lib/mysql &
echo " MariaDB started."

# Start Mailman
/usr/lib/mailman/bin/mailmanctl start
echo " Mailman started."

# Start cron and rsyslog
rsyslogd
crond
echo " rsyslog and cron started."

# Start Apache in foreground
echo " Starting Apache (Tuleap Web UI)..."
exec /usr/sbin/httpd -DFOREGROUND
