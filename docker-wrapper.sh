#!/bin/bash

# Start systemd
/usr/lib/systemd/systemd --system &
systemctl daemon-reload

function create-data-dirs {
    mkdir -p /data/etc/tuleap
    mkdir -p /data/etc/ssh
    mkdir -p /data/home
    mkdir -p /data/var/lib/tuleap
    mkdir -p /data/var/lib/gitolite
    mkdir -p /data/var/lib/mailman
    mkdir -p /data/var/lib/mysql
    mkdir -p /data/root
}

function move-data-dirs {
    [[ -d /etc/tuleap ]] && mv /etc/tuleap /data/etc/
    [[ -d /etc/ssh ]] && mv /etc/ssh /data/
    [[ -d /home ]] && mv /home /data/
    [[ -d /var/lib/tuleap ]] && mv /var/lib/tuleap /data/var/lib/
    [[ -d /var/lib/gitolite ]] && mv /var/lib/gitolite /data/var/lib/
    [[ -d /var/lib/mailman ]] && mv /var/lib/mailman /data/var/lib/
    [[ -d /var/lib/mysql ]] && mv /var/lib/mysql /data/var/lib/
    [[ -d /root ]] && mv /root /data/ && chmod 700 /data/root
}

function create-data-symlinks {
    [[ ! -L /etc/tuleap ]] && ln -s /data/etc/tuleap /etc/tuleap
    [[ ! -L /etc/ssh ]] && ln -s /data/etc/ssh /etc/ssh
    [[ ! -L /home ]] && ln -s /data/home /home
    [[ ! -L /var/lib/tuleap ]] && ln -s /data/var/lib/tuleap /var/lib/tuleap
    [[ ! -L /var/lib/gitolite ]] && ln -s /data/var/lib/gitolite /var/lib/gitolite
    [[ ! -L /var/lib/mailman ]] && ln -s /data/var/lib/mailman /var/lib/mailman
    [[ ! -L /var/lib/mysql ]] && ln -s /data/var/lib/mysql /var/lib/mysql
    [[ ! -L /root ]] && ln -s /data/root /root
}

function remove-data-dirs {
    [[ -d /etc/tuleap ]] && rm -rf /etc/tuleap
    [[ -d /etc/ssh ]] && rm -rf /etc/ssh
    [[ -d /home ]] && rm -rf /home
    [[ -d /var/lib/tuleap ]] && rm -rf /var/lib/tuleap
    [[ -d /var/lib/gitolite ]] && rm -rf /var/lib/gitolite
    [[ -d /var/lib/mailman ]] && rm -rf /var/lib/mailman
    [[ -d /var/lib/mysql ]] && rm -rf /var/lib/mysql
    [[ -d /root ]] && rm -rf /root
}

# Check if Tuleap is already configured
if [[ ! -e /etc/tuleap/conf/local.inc ]]; then
    # First time setup
    /usr/share/tuleap-install/setup.sh --disable-domain-name-check \
        --sys-default-domain=$DEFAULT_DOMAIN \
        --sys-org-name="$ORG_NAME" \
        --sys-long-org-name="$ORG_NAME"

    # Stop services before moving data
    systemctl stop httpd
    systemctl stop mysql
    systemctl stop sshd
    
    if [[ ! -e /data/etc/tuleap/conf/local.inc ]]; then
        create-data-dirs
        move-data-dirs
    else
        remove-data-dirs
    fi
    
    create-data-symlinks
    
    # Run database migrations
    /usr/lib/forgeupgrade/bin/forgeupgrade --config=/etc/tuleap/forgeupgrade/config.ini update
fi

# Start required services
systemctl start rsyslog
systemctl start sshd
systemctl start mariadb
systemctl start httpd
systemctl start crond
systemctl start mailman

# Enable services to start on boot
systemctl enable rsyslog
systemctl enable sshd
systemctl enable mariadb
systemctl enable httpd
systemctl enable crond
systemctl enable mailman

# Start Tuleap services and enable required plugins
echo "Enabling Tuleap plugins..."

# Git plugin (includes Git and GitGitolite)
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php git
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php git_gitolite

# Docman and Wiki plugins
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php docman
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php docman-embedded
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php docman-watermark
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php docman-ws
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php docman_embedded_files
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php docman_wiki

# Project management and tracker plugins
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php agiledashboard
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php cardwall
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php taskboard

# Jenkins integration (Hudson plugin for Tuleap)
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php hudson_git
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php hudson

# Additional useful plugins
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php tracker
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php tracker_encryption
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/tools/utils/admin/activate_plugin.php tracker_permissions

# Force plugin installation and configuration
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/src/common/plugin/pluginsadministration_utils.php install --all

# Display logs
echo "Tuleap container is running..."
journalctl -f -u httpd -u mariadb -u sshd