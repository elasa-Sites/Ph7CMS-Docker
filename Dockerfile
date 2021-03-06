

FROM ubuntu:18.04
# FROM dockerfile/ubuntu

ARG DEBIAN_FRONTEND=noninteractive


RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils

RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get -y install unzip wget apache2 phpmyadmin aptitude
RUN apt-get -y install php
RUN apt-get -y install php-all-dev
RUN apt-get -y install php-mbstring
RUN apt-get -y install php-gd
RUN apt-get -y install composer
RUN apt-get -y install php-mysql
RUN apt-get -y install sudo
RUN apt-get -y install mysql-client
RUN apt-get -y install vim 
RUN sudo aptitude -y install mariadb-server mariadb-client
RUN sudo aptitude -y install curl git php7.2 libapache2-mod-php7.2 php7.2-common php7.2-sqlite3 php7.2-curl php7.2-intl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-cli php7.2-zip 
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer


# Install MySQL from :https://github.com/dockerfile/mysql/blob/master/Dockerfile
RUN mkdir -p /var/run/mysqld
RUN chown mysql:mysql /var/run/mysqld
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
  rm -rf /var/lib/apt/lists/* 
  
  
  
#   && mkdir /usr/local/mysql \
# 	&& rm -rf /usr/local/mysql/mysql-test /usr/local/mysql/sql-bench \
# 	&& rm -rf /usr/local/mysql/bin/*-debug /usr/local/mysql/bin/*_embedded \
# 	&& find /usr/local/mysql -type f -name "*.a" -delete \
# 	&& apt-get update && apt-get install -y binutils && rm -rf /var/lib/apt/lists/* \
# 	&& { find /usr/local/mysql -type f -executable -exec strip --strip-all '{}' + || true; } \
# 	&& apt-get purge -y --auto-remove binutils
# ENV PATH $PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts



RUN \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf 
#   echo "mysqld_safe &" > /tmp/config && \
#   echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
#   echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
#   bash /tmp/config && \
#   rm -f /tmp/config

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["mysqld_safe"]

# Expose ports.
EXPOSE 3306

# End of MYSQL installation https://github.com/dockerfile/mysql/blob/master/Dockerfile
CMD ["mysqld", "--datadir=/var/lib/mysql", "--user=mysql"]

CMD ["/bin/bash", "mysql_DB.sh"]; #"/mysql_Database.sh"]


WORKDIR /tmp
RUN wget https://github.com/pH7Software/pH7-Social-Dating-CMS/archive/master.zip
RUN unzip master.zip 
RUN rm -rf master.zip
COPY ./php.ini /etc/php/7.2/apache2/php.ini
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

RUN mv pH7-Social-Dating-CMS-master /var/www/html/ph7builder
WORKDIR /var/www/html/ph7builder
RUN sudo composer install

RUN  chown -R www-data:www-data /var/www/html/ph7builder/
RUN  chmod -R 755 /var/www/html/ph7builder/

# Setup Apache.
# In order to run our Simpletest tests, we need to make Apache
# listen on the same port as the one we forwarded. Because we use
# 8080 by default, we set it up for that port.
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

RUN echo "Listen 8080" >> /etc/apache2/ports.conf
RUN echo "Listen 8081" >> /etc/apache2/ports.conf
RUN echo "Listen 8443" >> /etc/apache2/ports.conf
RUN echo "<VirtualHost *:80>\
     ServerAdmin admin@example.com\
     DocumentRoot /var/www/html/ph7builder\
     ServerName 127.0.0.1\
\
     <Directory /var/www/html/ph7builder/>\
          Options FollowSymlinks\
          AllowOverride All\
          Require all granted\
     </Directory>\
\
     ErrorLog ${APACHE_LOG_DIR}/error.log\
     CustomLog ${APACHE_LOG_DIR}/access.log combined\
\
</VirtualHost>"> /etc/apache2/sites-available/ph7builder.conf
RUN grep -qxF 'include "127.0.0.1 ph7builder"' /etc/hosts || echo "127.0.0.1 ph7builder">> /etc/hosts
RUN grep -qxF 'include "127.0.0.1 localhost"' /etc/hosts || echo "127.0.0.1 localhost">> /etc/hosts    
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2ensite ph7builder.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
