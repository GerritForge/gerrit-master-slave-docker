FROM gerrit-slave

# Install and Configure Apache2 
RUN apt-get install -y apache2 && a2enmod cgi
ADD server-git.conf /etc/apache2/sites-available/000-default.conf
ADD envvars /etc/apache2/

ADD start.sh /bin/
CMD /bin/start.sh

