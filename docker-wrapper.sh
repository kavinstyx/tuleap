#!/bin/bash

if [[ ! -e /etc/tuleap/conf/local.inc ]]; then
	echo -e "$DEFAULT_DOMAIN\n$ORG_NAME" | /usr/share/tuleap-install/setup.sh
	# Post configuration
	#yum install -y system-config-firewall-base && yum clean all
	#lokkit -s https -s http -s ssh
else
	#/sbin/service xinetd restart
	/sbin/service vsftpd restart
	#/sbin/service named restart
	#/sbin/service mailman restart </dev/null >/dev/null 2>/dev/null &
	/sbin/service mysqld restart
	/usr/lib/forgeupgrade/bin/forgeupgrade --config=/etc/tuleap/forgeupgrade/config.ini update # Update
	/sbin/service httpd restart
	/sbin/service crond restart
	#/sbin/service nscd restart
	#/sbin/service munin-node restart
	#/sbin/service nscd restart
	#/sbin/service openfire restart
fi

# Tail all logs
tail -f /var/log/httpd/*
