

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive


RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get -y install wget apache2
RUN apt-get -y install php
RUN apt-get -y install php-all-dev
RUN apt-get -y install php-mbstring
RUN apt-get -y install php-gd
RUN apt-get -y install composer
RUN apt-get -y install php-mysql
RUN apt-get -y install sudo
RUN apt-get -y install mysql-client
RUN apt-get -y install vim aptitude
RUN sudo apt-get -y install mariadb-server mariadb-client
RUN sudo apt-get -y install curl git php7.2 libapache2-mod-php7.2 php7.2-common php7.2-sqlite3 php7.2-curl php7.2-intl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-cli php7.2-zip 
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer


WORKDIR /tmp
RUN wget https://github.com/pH7Software/pH7-Social-Dating-CMS/archive/master.zip
RUN unzip master.zip
RUN mv pH7-Social-Dating-CMS-master /var/www/html/ph7builder
RUN /var/www/html/ph7builder
RUN sudo composer install

RUN  chown -R www-data:www-data /var/www/html/ph7builder/
RUN  chmod -R 755 /var/www/html/ph7builder/

RUN  systemctl restart apache2.service

RUN a2ensite ph7builder.conf
RUN a2enmod rewrite
RUN systemctl restart apache2.service
