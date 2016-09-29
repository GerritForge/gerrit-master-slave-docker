FROM gerritforge/gerrit-ubuntu15.04:2.11.9

USER root

# Configure Gerrit user SSH keys
RUN mkdir /var/gerrit/.ssh
ADD id_rsa.pub /var/gerrit/.ssh/authorized_keys

# Configure Gerrit
ADD gerrit.config /var/gerrit/etc/
ADD secure.config /var/gerrit/etc/

ADD wait-for-it.sh /bin/

CMD /bin/start.sh

# Install SSH Server connectivity
RUN apt-get install -y vim \
    sudo \
    net-tools \
    openssh-server
