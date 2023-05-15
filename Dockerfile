FROM ubuntu:20.04
MAINTAINER Ali Mangsur <alie.mangsur@gmail.com>

# Environments vars
ENV TERM=xterm

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update

# Packages installation
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --fix-missing install apache2 \
      php7.0 \
      php7.0-cli \
      php7.0-gd \
      php7.0-json \
      php7.0-mbstring \
      php7.0-xml \
      php7.0-xsl \
      php7.0-zip \
      php7.0-soap \
      php7.0-dev \
      php7.0-mcrypt \
      libapache2-mod-php \
      curl \
      php7.0-curl \
      apt-transport-https \
      nano \
      git

RUN a2enmod rewrite
RUN phpenmod mcrypt

# Composer install
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Update the default apache site
ADD config/apache/apache-virtual-hosts.conf /etc/apache2/sites-enabled/000-default.conf
ADD config/apache/apache2.conf /etc/apache2/apache2.conf
ADD config/apache/ports.conf /etc/apache2/ports.conf
ADD config/apache/envvars /etc/apache2/envvars

# Update php.ini
ADD config/php/php.conf /etc/php/7.0/apache2/php.ini

# MSQL server driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get -y install unixodbc-dev php-xml php-pear 
RUN pecl install sqlsrv-5.3.0
RUN pecl install pdo_sqlsrv-5.3.0

RUN echo "extension=pdo.so" >> /etc/php/7.0/apache2/php.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.0/apache2/php.ini
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.0/apache2/php.ini
RUN echo "extension=pdo.so" >> /etc/php/7.0/cli/php.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.0/cli/php.ini
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.0/cli/php.ini

# Install locales
RUN apt-get install locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen

# Init
ADD init.sh /init.sh
RUN chmod 755 /*.sh

RUN a2dismod php* 
RUN a2enmod php7.0
RUN update-alternatives --set php /usr/bin/php7.0
RUN update-alternatives --set phar /usr/bin/phar7.0 
RUN update-alternatives --set phar.phar /usr/bin/phar.phar7.0
RUN update-alternatives --set phpize /usr/bin/phpize7.0
RUN update-alternatives --set php-config /usr/bin/php-config7.0

RUN service apache2 restart

RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html/

# Volume
VOLUME /var/www/html

# Ports: apache2
EXPOSE 80

CMD ["/init.sh"]

