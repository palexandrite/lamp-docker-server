FROM php:7.4-apache

COPY ["hosts", "/etc/apache2/sites-enabled"]

COPY ["config/php/php.ini", "/usr/local/etc/php/conf.d"]

COPY ["domains", "/var/www"]

RUN a2enmod rewrite && service apache2 restart