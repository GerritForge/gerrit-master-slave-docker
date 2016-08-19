#!/bin/bash -ex

chown -R gerrit: /var/gerrit/.ssh
chmod 600 /var/gerrit/.ssh/id_rsa

wait-for-it.sh slave:22 -- echo "Slave is up"
sudo -u gerrit ssh -oStrictHostKeyChecking=no slave exit

wait-for-it.sh postgres:5432 -- echo "Postgres is up"
sudo -u gerrit rm -Rf /var/gerrit/git/*
sudo -u gerrit java -jar /var/gerrit/bin/gerrit.war init -d /var/gerrit --batch --install-plugin replication

/etc/init.d/gerrit start
tail -f /var/gerrit/logs/error_log

