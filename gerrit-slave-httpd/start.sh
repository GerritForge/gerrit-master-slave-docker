#!/bin/bash -ex

chown -R gerrit: /var/gerrit/.ssh
chmod 600 /var/gerrit/.ssh/authorized_keys

/etc/init.d/ssh start
/etc/init.d/apache2 start

wait-for-it.sh -t 60 gerrit-master:8080 -- echo "Gerrit master is up"
/etc/init.d/gerrit start &
touch /var/gerrit/logs/error_log && chown -R gerrit: /var/gerrit && tail -f /var/gerrit/logs/error_log
