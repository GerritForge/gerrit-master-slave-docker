FROM gerritforge/gerrit-ubuntu15.04:2.11.9

USER gerrit

RUN mkdir /var/gerrit/.ssh

ADD id_rsa.pub /var/gerrit/.ssh/authorized_keys

ADD gerrit.config /var/gerrit/etc/

ADD secure.config /var/gerrit/etc/

USER root

RUN apt-get install -y fcgiwrap nginx

RUN cp /usr/share/doc/fcgiwrap/examples/nginx.conf /etc/nginx/fcgiwrap.conf

RUN sed -i 's/www-data/gerrit/g' /etc/init.d/fcgiwrap

RUN apt-get install -y vim

RUN apt-get install -y sudo

RUN apt-get install -y net-tools

ADD start.sh /bin

ADD nginx.conf /etc/nginx/

ADD server-git.conf /etc/nginx/sites-enabled/

RUN apt-get install -y openssh-server

ADD wait-for-it.sh /bin/

CMD /bin/start.sh





