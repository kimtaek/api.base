FROM ubuntu:18.04
MAINTAINER Kimtaek <jinze1991@icloud.com>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales tzdata \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8

ENV DEBCONF_NOWARNINGS yes
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# Install PHP-CLI 7, some PHP extentions and some useful Tools with APT
RUN mkdir -p /run/php
RUN apt-get install -y software-properties-common dialog
RUN add-apt-repository ppa:ondrej/php
#RUN apt-get update
RUN apt-get install -y \
        php7.3 \
        php7.3-fpm \
        php7.3-cli \
        php7.3-common \
        php7.3-bcmath \
        php7.3-mbstring \
        php7.3-soap \
        php7.3-xml \
        php7.3-zip \
        php7.3-apcu \
        php7.3-json \
        php7.3-gd \
        php7.3-curl \
        php7.3-mysql \
        php7.3-xdebug \
        php7.3-imap \
        cron \
        curl \
        supervisor \
        nginx \
        vim

RUN rm -rf /etc/php/5.6 /etc/php/7.0 /etc/php/7.1 /etc/php/7.2
RUN apt-get clean

# Php.ini
RUN sed -ri "s/post_max_size = 8M/post_max_size = 128M/g" /etc/php/7.3/fpm/php.ini
RUN sed -ri "s/upload_max_filesize = 2M/upload_max_filesize = 32M/g" /etc/php/7.3/fpm/php.ini
RUN sed -ri "s/memory_limit = 128M/memory_limit = 256M/g" /etc/php/7.3/fpm/php.ini

RUN echo 'opcache.enable=1 \n\
opcache.enable_cli=1 \n\
opcache.memory_consumption=512 \n\
opcache.interned_strings_buffer=64 \n\
opcache.max_accelerated_files=32531 \n\
opcache.validate_timestamps=0 \n\
opcache.save_comments=1 \n\
opcache.fast_shutdown=0' >> /etc/php/7.3/fpm/conf.d/10-opcache.ini

# php-fpm.ini
# RUN echo '; Custom configs, recommend for over 8G memory\n\
# pm=static \n\
# pm.max_children=300 \n\
# pm.start_servers=20 \n\
# pm.min_spare_servers=5 \n\
# pm.max_spare_servers=30 \n\
# pm.max_requests=10240 \n\
# request_terminate_timeout=30' >> /etc/php/7.3/fpm/php-fpm.conf

# php-fpm.ini
RUN echo '; Custom configs, recommend for under 8G memory \n\
pm=dynamic \n\
pm.max_children=50 \n\
pm.start_servers=20 \n\
pm.min_spare_servers=10 \n\
pm.max_spare_servers=30 \n\
pm.max_requests=10240 \n\
request_terminate_timeout=30' >> /etc/php/7.3/fpm/php-fpm.conf

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /www
EXPOSE 80 443 9001
