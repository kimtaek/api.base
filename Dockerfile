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
RUN rm -Rf /etc/php/*
RUN apt-get install -y dialog
RUN apt-get install -y \
        php7.2 \
        php7.2-fpm \
        php7.2-cli \
        php7.2-common \
        php7.2-bcmath \
        php7.2-mbstring \
        php7.2-soap \
        php7.2-xml \
        php7.2-zip \
        php7.2-apcu \
        php7.2-json \
        php7.2-gd \
        php7.2-curl \
        php7.2-mysql \
        php7.2-xdebug \
        php7.2-imap \
        cron \
        curl \
        supervisor \
        nginx \
        vim

RUN sed -ri "s/upload_max_filesize = 2M/upload_max_filesize = 8M/g" /etc/php/7.2/fpm/php.ini
RUN echo 'opcache.enable=1 \n\
opcache.memory_consumption=512 \n\
opcache.interned_strings_buffer=16 \n\
opcache.max_accelerated_files=32531 \n\
opcache.validate_timestamps=0 \n\
opcache.save_comments=1 \n\
opcache.fast_shutdown=0' >> /etc/php/7.2/fpm/conf.d/10-opcache.ini

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /www
EXPOSE 80 443 9001
