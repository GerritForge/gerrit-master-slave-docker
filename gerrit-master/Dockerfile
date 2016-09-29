FROM gerritforge/gerrit-ubuntu15.04:2.13.1

USER root

RUN apt-get install -y openjdk-8-jdk && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    apt-get install -y iputils-ping netcat


USER gerrit

ADD gerrit.config /var/gerrit/etc/
ADD secure.config /var/gerrit/etc/
ADD replication.config /var/gerrit/etc/

RUN mkdir /var/gerrit/.ssh
ADD id_rsa /var/gerrit/.ssh
ADD id_rsa.pub /var/gerrit/.ssh
ADD config /var/gerrit/.ssh

USER root

RUN apt-get install -y net-tools netcat inetutils-ping

ADD start.sh /bin/
ADD wait-for-it.sh /bin/

CMD /bin/start.sh
