# Gerrit master + slave Docker playground

Example of set-up of a Gerrit master-slave replication scenario.

This docker compose configuration creates the following scenario:
- Gerrit DB on PostgreSQL shared between master and slaves
- Gerrit master listening to port 18080 (Web and Git/HTTP) and 29418 (Git/SSH) with "development_become_any_account" authentication
- First Gerrit slave listening to port 18081 (Git/HTTP) 
- Second Gerrit slave listening to port 18082 (Git/HTTP)
- Gerrit user 'admin' with password 'secret'

## Pre-requisites

- Docker 1.12.x 
- Docker compose 1.8 or later
- Linux or MacOS operating systems
- GNU make (standard on Linux and MacOS)

## How to start

Just type 'make' to trigger the Docker images download and startup.

Example:
```
$ make
[...]
Successfully built d7ed58376801
docker-compose up -d
Creating gerritmasterslavedocker_postgres_1
Creating gerritmasterslavedocker_gerrit-master_1
Creating gerritmasterslavedocker_gerrit-slave-httpd_1
Creating gerritmasterslavedocker_gerrit-slave-nginx_1
```

## Display the VMs

To display list of docker VMs active type 'make status'

Example:
```
$ make status
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                               NAMES
9dd54f6ded91        gerrit-slave-nginx   "/bin/sh -c /bin/star"   11 seconds ago      Up 9 seconds        29418/tcp, 0.0.0.0:18081->8080/tcp                  gerritmasterslavedocker_gerrit-slave-nginx_1
d5d1b91706e3        gerrit-slave-httpd   "/bin/sh -c /bin/star"   11 seconds ago      Up 9 seconds        29418/tcp, 0.0.0.0:18082->8080/tcp                  gerritmasterslavedocker_gerrit-slave-httpd_1
3c04ba9a7e87        gerrit-master        "/bin/sh -c /bin/star"   12 seconds ago      Up 10 seconds       0.0.0.0:29418->29418/tcp, 0.0.0.0:18080->8080/tcp   gerritmasterslavedocker_gerrit-master_1
6d4adba0cac2        postgres:9.5.4       "/docker-entrypoint.s"   13 seconds ago      Up 11 seconds       5432/tcp                                            gerritmasterslavedocker_postgres_1
```

## Display the logs

Each of the VM has associated a SHA1. If you want to display the logs of
one of them, type the command 'docker logs <SHA1>'.

Example:
```
$ docker logs 3c04ba9a7e87
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
http://localhost:18080

On the top-right choose "Become" and select "Administrator" to login as admin user.
You can then create a new repository, called test-project, from the "Projects" and then "Create New Project" menu.
Enter the "test-project" in the Project Name, select "Create initial empty commit" field and press the "Create Project" button.

### Cloning the project from one of the slaves

To clone the projects from one of the slaves, use one of the following URLs:

- http://localhost:18081/test-project
- http://localhost:18082/test-project

### Pushing to Gerrit master

To push new changes to Gerrit master, use the following URL:

- http://localhost:18080/test-project

