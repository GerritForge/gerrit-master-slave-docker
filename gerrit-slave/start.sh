#!/bin/bash -ex

chown -R gerrit: /var/gerrit/.ssh
chmod 600 /var/gerrit/.ssh/authorized_keys

/etc/init.d/ssh start
/etc/init.d/nginx start
/etc/init.d/fcgiwrap start

wait-for-it.sh master:8080 -- echo "Master is up"
/etc/init.d/gerrit start
tail -f /var/gerrit/logs/error_log
