FROM php:7.4-apache

ARG COMPOSER_VERSION="2.0.11"

# Install php extensions and assistive Linux extensions
RUN apt-get update && apt-get install -y \
        git \
        wget \
        # For GD
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        \
        # For the intl php extension
        libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mysqli fileinfo intl sockets

# Remove all *.ini files from the php.ini secondary config directory
# to make my own php.ini as a basic
RUN rm -rf /usr/local/etc/php/conf.d/*

# Install composer
RUN mkdir /etc/composer \
    && wget https://getcomposer.org/installer -P /etc/composer \
    && cd /etc/composer \
    && php -r "if (hash_file('sha384', 'installer') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('installer'); } echo PHP_EOL;" \
    && php ./installer  --filename=composer --install-dir=/bin --version=${COMPOSER_VERSION} \
    && rm /etc/composer/installer \
    && chmod a+x /bin/composer

# Switch on the mod_rewrite of Apache
RUN a2enmod rewrite && service apache2 restart

COPY ["hosts", "/etc/apache2/sites-enabled"]

COPY ["config/php", "/usr/local/etc/php"]

COPY ["domains", "/var/www"]