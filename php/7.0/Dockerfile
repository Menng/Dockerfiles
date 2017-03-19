FROM debian:jessie

MAINTAINER Menng

# Set timezone
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Set DNS Server
RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf
RUN echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# Replace source list
RUN sed -i -e "s/httpredir.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
RUN sed -i -e "s/security.debian.org/mirrors.aliyun.com\/debian-security/g" /etc/apt/sources.list

# Upgrade System
RUN apt-get update

# Install Compile Tool
ENV PHPIZE_DEPS \
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
    re2c

RUN apt-get install -y \
    $PHPIZE_DEPS \
    ca-certificates \
    libedit2 \
    libsqlite3-0 \
    libxml2 \
    wget \
    --no-install-recommends

# Install Requirements
RUN apt-get install -y \
    libxml2-dev libpcre3-dev libjpeg62-turbo-dev libfreetype6-dev libpng12-dev libpng3 \
    libpnglite-dev libiconv-hook-dev libiconv-hook1 libmcrypt-dev libmcrypt4 libmhash-dev \
    libmhash2 libltdl-dev libssl-dev libcurl4-openssl-dev libxslt1-dev libbz2-dev libtidy-dev \
    libmysqlclient-dev --no-install-recommends

ENV PHP_BUILD_DIR /usr/local/php7
ENV PHP_CONF_DIR $PHP_BUILD_DIR/etc
ENV PHP_CONF_SCAN_DIR $PHP_CONF_DIR/php-fpm.d
ENV PHPIZE $PHP_BUILD_DIR/bin/phpize

ENV PHP_VERSION 7.0.13
ENV PHP_FILENAME php-$PHP_VERSION.tar.gz
ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763
ENV PHP_SHA256 c8d8cf1b29e7f7e89be9ee64f453cb7ef6d20e1d13a83cba037bd654ef2da42c

# Download PHP Source code
RUN wget -O "$PHP_FILENAME" "http://cn2.php.net/get/$PHP_FILENAME/from/this/mirror" \
    && echo "$PHP_SHA256 $PHP_FILENAME" | sha256sum -c - \
    && wget -O "$PHP_FILENAME.asc" "http://php.net/get/$PHP_FILENAME.asc/from/this/mirror" \
    && export GNUPGHOME="$(mktemp -d)" \
    && for key in $GPG_KEYS; do \
      gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done \
    && gpg --batch --verify "$PHP_FILENAME.asc" "$PHP_FILENAME" \
    && rm -r "$GNUPGHOME" "$PHP_FILENAME.asc" \
    && tar -zxf "$PHP_FILENAME" -C /usr/local/src/ \
    && rm "$PHP_FILENAME"


# Compile Source Code
RUN cd /usr/local/src/php-$PHP_VERSION \
    && ./configure \
    --prefix=$PHP_BUILD_DIR \
    --with-config-file-path=$PHP_CONF_DIR \
    --with-config-file-scan-dir=$PHP_CONF_SCAN_DIR \
    --with-gd \
    --with-xsl \
    --with-bz2 \
    --with-curl \
    --with-zlib \
    --with-tidy \
    --with-mhash \
    --with-mysqli \
    --with-xmlrpc \
    --with-mcrypt \
    --with-gettext \
    --with-png-dir \
    --with-openssl \
    --with-kerberos \
    --with-iconv-dir \
    --with-pdo-mysql \
    --with-pdo-sqlite \
    --with-libxml-dir \
    --with-pcre-regex \
    --with-freetype-dir \
    --with-libdir=lib64 \
    --without-pear \
    --disable-rpath \
    --enable-inline-optimization \
    --enable-maintainer-zts \
    --enable-gd-native-ttf \
    --enable-mbstring \
    --enable-mbregex \
    --enable-opcache \
    --enable-mysqlnd \
    --enable-sockets \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-libxml \
    --enable-bcmath \
    --enable-phpdbg \
    --enable-shmop \
    --enable-pcntl \
    --enable-debug \
    --enable-soap \
    --enable-exif \
    --enable-fpm \
    --enable-xml \
    --enable-zip

RUN cd /usr/local/src/php-$PHP_VERSION && \
    make && make install

# Search in https://pecl.php.net/index.php get name
RUN for key in xdebug-2.5.0 mongodb-1.1.9 pthreads-2.0.10 redis-3.0.0; do \
        cd /tmp \
        && wget -O "$key".tgz https://pecl.php.net/get/"$key".tgz \
        && tar zxf "$key".tgz -C /tmp/ \
        && cd /tmp/"$key" \
        && $PHPIZE \
        && ./configure --with-php-config=$PHP_BUILD_DIR/bin/php-config \
        && make && make install \
        && cd /tmp \
        && rm -rf "$key"*; \
    done

# Configure PHP
RUN cp /usr/local/src/php-$PHP_VERSION/sapi/fpm/php-fpm $PHP_BUILD_DIR/bin
RUN cp /usr/local/src/php-$PHP_VERSION/php.ini-production $PHP_CONF_DIR/php.ini
RUN cp $PHP_CONF_DIR/php-fpm.conf.default $PHP_CONF_DIR/php-fpm.conf
RUN sed -i "s/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g" $PHP_CONF_DIR/php-fpm.conf
RUN sed -i "s/;error_log = log\/php-fpm.log/error_log = log\/php-fpm.log/g" $PHP_CONF_DIR/php-fpm.conf
RUN sed -i "s/;daemonize = yes/daemonize = no/g" $PHP_CONF_DIR/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" $PHP_CONF_DIR/php.ini

# Configure www.conf
RUN cp $PHP_CONF_SCAN_DIR/www.conf.default $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/user = nobody/user = www-data/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/group = nobody/group = www-data/g" $PHP_CONF_SCAN_DIR/www.conf
# RUN sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/listen = 127.0.0.1:9000/listen = 9000/g" $PHP_CONF_SCAN_DIR/www.conf
# RUN sed -i "s/;listen.owner = nobody/listen.owner = www-data/g" $PHP_CONF_SCAN_DIR/www.conf
# RUN sed -i "s/;listen.group = nobody/listen.group = www-data/g" $PHP_CONF_SCAN_DIR/www.conf
# RUN sed -i "s/;listen.mode = 0660/listen.mode = 0660/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/pm.max_children = 5/pm.max_children = 75/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/pm.start_servers = 2/pm.start_servers = 10/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = 5/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 10/g" $PHP_CONF_SCAN_DIR/www.conf
RUN sed -i "s/;pm.max_requests = 500/pm.max_requests = 500/g" $PHP_CONF_SCAN_DIR/www.conf

# Enable php extension
RUN echo 'extension_dir = "/usr/local/php7/lib/php/extensions/debug-zts-20151012"' >> $PHP_CONF_DIR/php.ini
RUN echo 'extension=redis.so' >> $PHP_CONF_DIR/php.ini
RUN echo 'extension=mongodb.so' >> $PHP_CONF_DIR/php.ini
RUN echo 'extension=pthreads.so' >> $PHP_CONF_DIR/php.ini
RUN echo 'zend_extension=opcache.so' >> $PHP_CONF_DIR/php.ini

# Configure opcache
RUN sed -i "s/;opcache.enable=0/opcache.enable=1/g" $PHP_CONF_DIR/php.ini
RUN sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/g" $PHP_CONF_DIR/php.ini
RUN sed -i "s/;opcache.file_cache=/opcache.file_cache=\/tmp/g" $PHP_CONF_DIR/php.ini
RUN sed -i "s/;opcache.huge_code_pages=1/opcache.huge_code_pages=1/g" $PHP_CONF_DIR/php.ini

# Create the system startup command
ADD php7.0-fpm /etc/init.d/php7.0-fpm
ADD xdebug.ini $PHP_CONF_SCAN_DIR/xdebug.ini
RUN chmod 755 /etc/init.d/php7.0-fpm
RUN update-rc.d php7.0-fpm defaults

# Clean
RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove -y
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $PHPIZE_DEPS

# Define working directory
WORKDIR $PHP_BUILD_DIR

# Define default command
CMD ["service","php7.0-fpm","start"]

# Expose Ports
EXPOSE 9000
