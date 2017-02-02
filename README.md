# Gerrit haproxy + master + slave Docker playground

Example of set-up of a Gerrit master-slave replication scenario load balanced with haproxy.

This docker compose configuration creates the following scenario:
- Gerrit DB on PostgreSQL shared between master and slaves
- Gerrit master listening to port 18080 (Web and Git/HTTP) and 29418 (Git/SSH) with "development_become_any_account" authentication
- First Gerrit slave listening to port 18081 (Git/HTTP) 
- Second Gerrit slave listening to port 18082 (Git/HTTP)
- Gerrit user 'admin' with password 'secret'
- Nginx web server listening to port 80 to serve gerrit static assets
- HaProxy listening on port 80 that redirects traffic to either the master, slaves, or static servers

## Pre-requisites

- Docker 1.12.x 
- Docker compose 1.8 or later
- Linux or MacOS operating systems
- GNU make (standard on Linux and MacOS)

## How to start

Just type 'make' or 'docker-compose build' to trigger the Docker images download and startup.

Example:
```
$ make
[...]
Successfully built d7ed58376801
docker-compose up -d
Creating gerritmasterslavedocker_postgres_1
Creating gerritmasterslavedocker_gerrit-master-nginx_1
Creating gerritmasterslavedocker_gerrit-slave-httpd_1
Creating gerritmasterslavedocker_gerrit-slave-nginx_1
Creating gerritmasterslavedocker_gerrit-haproxy_1
```

## Display the VMs

To display list of docker VMs active type 'make status'

Example:
```
$ docker-compose ps
                     Name                                   Command               State                         Ports
-------------------------------------------------------------------------------------------------------------------------------------------
gerritmasterslavedocker_gerrit-haproxy_1         /docker-entrypoint.sh hapr ...   Up      0.0.0.0:80->80/tcp
gerritmasterslavedocker_gerrit-master-nginx_1    /bin/sh -c /bin/start.sh         Up      0.0.0.0:29418->29418/tcp, 0.0.0.0:18080->8080/tcp
gerritmasterslavedocker_gerrit-slave-httpd_1     /bin/sh -c /bin/start.sh         Up      29418/tcp, 0.0.0.0:18082->8080/tcp
gerritmasterslavedocker_gerrit-slave-nginx_1     /bin/sh -c /bin/start.sh         Up      29418/tcp, 0.0.0.0:18081->8080/tcp
gerritmasterslavedocker_gerrit-static-nginx_1    nginx -g daemon off;             Up      443/tcp, 0.0.0.0:18083->80/tcp
gerritmasterslavedocker_postgres_1               /docker-entrypoint.sh postgres   Up      5432/tcp
```

## Display the logs

Each of the VM has associated a SHA1. If you want to display the logs of
one of them, type the command 'docker logs <SHA1>'.

Example:
```
$ docker-compose logs gerrit-master-nginx
+ chown -R gerrit: /var/gerrit/.ssh
+ chmod 600 /var/gerrit/.ssh/id_rsa
+ wait-for-it.sh gerrit-slave-nginx:22 -- echo 'Slave is up'
wait-for-it.sh: waiting 15 seconds for gerrit-slave-nginx:22
wait-for-it.sh: gerrit-slave-nginx:22 is available after 2 seconds
Slave is up
+ sudo -u gerrit ssh -oStrictHostKeyChecking=no gerrit-slave-nginx exit
Warning: Permanently added 'gerrit-slave-nginx,172.18.0.5' (ECDSA) to the list of known hosts.
+ wait-for-it.sh gerrit-slave-httpd:22 -- echo 'Slave is up'
wait-for-it.sh: waiting 15 seconds for gerrit-slave-httpd:22
wait-for-it.sh: gerrit-slave-httpd:22 is available after 0 seconds
Slave is up
+ sudo -u gerrit ssh -oStrictHostKeyChecking=no gerrit-slave-httpd exit
Warning: Permanently added 'gerrit-slave-httpd,172.18.0.4' (ECDSA) to the list of known hosts.
+ wait-for-it.sh postgres:5432 -- echo 'Postgres is up'
wait-for-it.sh: waiting 15 seconds for postgres:5432
wait-for-it.sh: postgres:5432 is available after 3 seconds
Postgres is up
+ sudo -u gerrit rm -Rf /var/gerrit/git/All-Projects.git /var/gerrit/git/All-Users.git
+ sudo -u gerrit java -jar /var/gerrit/bin/gerrit.war init -d /var/gerrit --batch --install-plugin replication
Initialized /var/gerrit
+ /etc/init.d/gerrit start
sh: echo: I/O error
Starting Gerrit Code Review: OK
+ tail -f /var/gerrit/logs/error_log
[2016-10-03 07:30:38,181] [main] INFO  com.google.gerrit.server.git.LocalDiskRepositoryManager : Defaulting core.streamFileThreshold to 148m
[2016-10-03 07:30:38,852] [main] INFO  com.google.gerrit.server.plugins.PluginLoader : Loading plugins from /var/gerrit/plugins
[2016-10-03 07:30:39,165] [main] INFO  com.google.gerrit.server.plugins.PluginLoader : Loaded plugin replication, version v2.13.1
[2016-10-03 07:30:39,167] [main] INFO  com.google.gerrit.server.change.ChangeCleanupRunner : Ignoring missing changeCleanup schedule configuration
[2016-10-03 07:30:39,240] [main] INFO  com.google.gerrit.sshd.SshDaemon : Started Gerrit SSHD-CORE-1.2.0 on *:29418
[2016-10-03 07:30:39,248] [main] INFO  org.eclipse.jetty.server.Server : jetty-9.2.14.v20151106
[2016-10-03 07:30:39,927] [main] INFO  org.eclipse.jetty.server.handler.ContextHandler : Started o.e.j.s.ServletContextHandler@7238c3bf{/,null,AVAILABLE}
[2016-10-03 07:30:39,938] [main] INFO  org.eclipse.jetty.server.ServerConnector : Started ServerConnector@69444b07{HTTP/1.1}{0.0.0.0:8080}
[2016-10-03 07:30:39,940] [main] INFO  org.eclipse.jetty.server.Server : Started @15480ms
[2016-10-03 07:30:39,942] [main] INFO  com.google.gerrit.pgm.Daemon : Gerrit Code Review 2.13.1 ready
```

### Access Gerrit master and slaves

Assuming you are running Docker on your localhost, open the Gerrit master Web GUI at:

- http://localhost

On the top-right choose "Become" and select "Administrator" to login as admin user.
You can then create a new repository, called test-project, from the "Projects" and then "Create New Project" menu.
Enter the "test-project" in the Project Name, select "Create initial empty commit" field and press the "Create Project" button.

### Load balance

There is a haproxy frontend that will redirect all git clones/fetch requests to the slaves, all documentation requests
to nginx web server and everything else gets redirected to the gerrit master.  Traffic to the servers are load balanced
in round robin manner.

- Cloning/Pushing: http://localhost/test-project
- Haproxy stats: http://localhost/haproxy?stats
- Username/password: admin/secret

### Clone/Pushing

To clone and push new changes use the following URL:

- http://localhost/test-project


### Bypassing haproxy

The ports to the master and slaves are exposed for testing.

#### Cloning the project from the master

To access Gerrit UI directly on the master use the following URL:

- http://localhost:18080

To clone projects directly from the master use the following URL:

- http://localhost:18080/test-project


#### Cloning the project from one of the slaves

To clone the projects directly from one of the slaves, use one of the following URLs:

- http://localhost:18081/test-project
- http://localhost:18082/test-project

Slaves are read only git servers therefore pushes to slaves are not allowed.