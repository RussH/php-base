FROM php:5.6.27-fpm-alpine
RUN apk upgrade --update && apk add \
  coreutils \
  freetype-dev \
  libjpeg-turbo-dev \
  libltdl \
  libmcrypt-dev \
  libpng-dev \
  antiword \
  poppler-utils \
  html2text \
  alpine-sdk \
  autoconf \
  automake
RUN cd ~ && \
  wget http://www.gnu.org/software/unrtf/unrtf-0.21.9.tar.gz && \
  tar xzvf unrtf-0.21.9.tar.gz && \
  cd unrtf-0.21.9/ && \
  ./bootstrap && \
  ./configure && \
  make && \
  make install
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j5 mysql gd ldap soap zip opcache
ADD scripts/install-composer.sh /opt/install-composer.sh
ADD scripts/entrypoint.sh /opt/entrypoint.sh
RUN dos2unix /opt/install-composer.sh && \
  chmod +x /opt/install-composer.sh && \
  /opt/install-composer.sh && \
  mv /var/www/html/composer.phar /usr/local/bin/composer
ENV DOCKERIZE_VERSION v0.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN echo "date.timezone='UTC'" > /usr/local/etc/php/conf.d/timezone.ini && \
        echo "realpath_cache_size = 4096k" >> /usr/local/etc/php/conf.d/cache.ini && \
        echo "realpath_cache_ttl = 7200" >> /usr/local/etc/php/conf.d/cache.ini  && \
        echo "error_log = /dev/stderr" >> /usr/local/etc/php/conf.d/error_log.ini  && \
        echo "log_errors = On" >> /usr/local/etc/php/conf.d/error_log.ini && \
        echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/error_log.ini
WORKDIR /var/www
CMD ["/opt/entrypoint.sh"]
