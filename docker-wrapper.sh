#!/bin/bash

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
        mv /etc/tuleap /data/etc/
        mv /etc/ssh /data/
        mv /home /data/
        mv /var/lib/tuleap /data/var/lib/
        mv /var/lib/gitolite /data/var/lib/
        mv /var/lib/mailman /data/var/lib/
        mv /var/lib/mysql /data/var/lib/
        mv /root /data/ && chmod 700 /data/root
}

function create-data-symlinks {
	ln -s /data/etc/tuleap /etc/tuleap
        ln -s /data/etc/ssh /etc/ssh
        ln -s /data/home /home
        ln -s /data/var/lib/tuleap /var/lib/tuleap
        ln -s /data/var/lib/gitolite /var/lib/gitolite
        ln -s /data/var/lib/mailman /var/lib/mailman
        ln -s /data/var/lib/mysql /var/lib/mysql
        ln -s /data/root /root
}

function remove-data-dirs {
        rm -rf /etc/tuleap
        rm -rf /etc/ssh 
        rm -rf /home 
        rm -rf /var/lib/tuleap 
        rm -rf /var/lib/gitolite 
        rm -rf /var/lib/mailman 
        rm -rf /var/lib/mysql 
        rm -rf /root
}

if [[ ! -e /etc/tuleap/conf/local.inc ]]; then
	/usr/share/tuleap-install/setup.sh --disable-domain-name-check --sys-default-domain=$DEFAULT_DOMAIN --sys-org-name=$DEFAULT_DOMAIN --sys-long-org-name=$DEFAULT_DOMAIN
	# Post configuration
	#yum install -y system-config-firewall-base && yum clean all
	#lokkit -s https -s http -s ssh
	service --status-all | grep running... | awk '{print $1;}' | xargs -l -I{} service {} stop
	if [[ ! -e /data/etc/tuleap/conf/local.inc ]]; then
		create-data-dirs
	        move-data-dirs
	else
		remove-data-dirs
	fi
	create-data-symlinks
	/usr/lib/forgeupgrade/bin/forgeupgrade --config=/etc/tuleap/forgeupgrade/config.ini update # Update
fi
#/sbin/service xinetd restart
/sbin/service vsftpd restart
#/sbin/service named restart
/sbin/service mailman restart </dev/null >/dev/null 2>/dev/null &
/sbin/service mysqld restart
/sbin/service httpd restart
/sbin/service crond restart
#/sbin/service nscd restart
#/sbin/service munin-node restart
#/sbin/service nscd restart
#/sbin/service openfire restart

# Tail all logs
tail -f /var/log/httpd/*
