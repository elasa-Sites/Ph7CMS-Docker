#!/bin/bash


/usr/bin/mysqld_safe & 
sleep 2s
# Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
PH7CMS_DB="ph7builder"
MYSQL_PASSWORD=`password`
#This is so the passwords show up in logs. 
echo mysql root password: $MYSQL_PASSWORD
echo wordpress password: $WORDPRESS_PASSWORD

mysqladmin -u root password $MYSQL_PASSWORD 
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE $PH7CMS_DB; GRANT ALL PRIVILEGES ON $PH7CMS_DB.* TO 'PH7CMS'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
killall mysqld
sleep 2s

supervisord -n
