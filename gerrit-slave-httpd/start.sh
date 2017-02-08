#!/bin/bash -ex

chown -R gerrit: /var/gerrit/.ssh
chmod 600 /var/gerrit/.ssh/authorized_keys

/etc/init.d/ssh start
/etc/init.d/apache2 start

wait-for-it.sh -t 60 gerrit-master-nginx-blue:8019 -- echo "Gerrit master blue is up"
wait-for-it.sh -t 60 gerrit-master-nginx-green:8020 -- echo "Gerrit master green is up"
/etc/init.d/gerrit start &
touch /var/gerrit/logs/error_log && chown -R gerrit: /var/gerrit && tail -f /var/gerrit/logs/error_log
