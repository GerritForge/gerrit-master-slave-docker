FROM gerrit-master

USER root

# Install and Configure NGINX and other system tools
RUN apt-get install -y fcgiwrap nginx && \
    cp /usr/share/doc/fcgiwrap/examples/nginx.conf /etc/nginx/fcgiwrap.conf && \
    sed -i 's/www-data/gerrit/g' /etc/init.d/fcgiwrap
ADD nginx.conf /etc/nginx/
ADD server-git.conf /etc/nginx/sites-enabled/

USER gerrit

ADD gerrit.config /var/gerrit/etc/
ADD secure.config /var/gerrit/etc/
# ADD replication.config /var/gerrit/etc/

USER root

ADD start.sh /bin/
CMD /bin/start.sh

