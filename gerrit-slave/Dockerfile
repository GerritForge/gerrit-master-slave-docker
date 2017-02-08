FROM gerritforge/gerrit-ubuntu15.04:2.13.5

USER root

RUN apt-get install -y openjdk-8-jdk && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    apt-get install -y iputils-ping netcat

# Configure Gerrit user SSH keys
RUN mkdir /var/gerrit/.ssh
ADD id_rsa.pub /var/gerrit/.ssh/authorized_keys

# Configure Gerrit
ADD gerrit.config /var/gerrit/etc/
ADD secure.config /var/gerrit/etc/

ADD wait-for-it.sh /bin/

# Install SSH Server connectivity
RUN apt-get install -y vim \
    sudo \
    net-tools \
    openssh-server
