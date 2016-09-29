FROM gerritforge/gerrit-ubuntu15.04:2.11.9

USER root

# Configure Gerrit user SSH keys
RUN mkdir /var/gerrit/.ssh
ADD id_rsa.pub /var/gerrit/.ssh/authorized_keys

# Configure Gerrit
ADD gerrit.config /var/gerrit/etc/
ADD secure.config /var/gerrit/etc/
ADD start.sh /bin

ADD wait-for-it.sh /bin/

CMD /bin/start.sh

# Install and Configure NGINX and other system tools
RUN apt-get install -y fcgiwrap nginx && \
    cp /usr/share/doc/fcgiwrap/examples/nginx.conf /etc/nginx/fcgiwrap.conf && \
    sed -i 's/www-data/gerrit/g' /etc/init.d/fcgiwrap && \
    apt-get install -y vim \
    sudo \
    net-tools \
    openssh-server
ADD nginx.conf /etc/nginx/
ADD server-git.conf /etc/nginx/sites-enabled/
