#!/bin/bash -ex

chown -R gerrit: /var/gerrit/.ssh
chmod 600 /var/gerrit/.ssh/id_rsa
chmod 600 /var/gerrit/.ssh/authorized_keys

/etc/init.d/ssh start
/etc/init.d/nginx start
/etc/init.d/fcgiwrap start

wait-for-it.sh gerrit-slave-nginx:22 -- echo "Slave is up"
sudo -u gerrit ssh -oStrictHostKeyChecking=no gerrit-slave-nginx exit
wait-for-it.sh gerrit-slave-httpd:22 -- echo "Slave is up"
sudo -u gerrit ssh -oStrictHostKeyChecking=no gerrit-slave-httpd exit

wait-for-it.sh postgres:5432 -- echo "Postgres is up"
sudo -u gerrit rm -Rf /var/gerrit/git/*
sudo -u gerrit java -jar /var/gerrit/bin/gerrit.war init -d /var/gerrit --batch --install-all-plugins

/etc/init.d/gerrit start &
touch /var/gerrit/logs/error_log /var/gerrit/logs/http_log /var/gerrit/logs/replication_log && chown -R gerrit: /var/gerrit && tail -f /var/gerrit/logs/*

