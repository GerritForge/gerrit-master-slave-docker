FROM gerrit-slave

# Install and Configure Apache2 
RUN apt-get install -y apache2
ADD server-git.conf /etc/apache2/sites-available/000-default.conf
ADD start.sh /bin

