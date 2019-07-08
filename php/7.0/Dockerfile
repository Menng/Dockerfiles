FROM alpine:3.10

MAINTAINER Menng

# Setup DNS Server
RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf
RUN echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# Replace source list
RUN sed -i -e "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories

# Upgrade System
RUN apk update
RUN apk upgrade

# Setup timezone
RUN apk add --update --no-cache tzdata
ENV TZ Asia/Shanghai

# Install Compile Tool
ENV PHPIZE_DEPS \
    build-base \
    autoconf \
    bison \
    re2c

RUN apk add --no-cache \
    $PHPIZE_DEPS \
    ca-certificates \
    libedit \
    sqlite \
    libxml2 \
    wget

# Install Requirements
RUN apk add --no-cache \
    libxml2-dev \
    libpcre32 \
    libjpeg \
    libwebp-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libpng-dev \
    libltdl \
    libintl \
    libxslt-dev \
    bzip2-dev \
    openssl-dev \
    curl-dev \
    gettext-dev

ENV PHP_BUILD_DIR /usr/local/php70
ENV PHP_CONF_DIR $PHP_BUILD_DIR/etc
ENV PHP_CONF_SCAN_DIR $PHP_CONF_DIR/php-fpm.d
ENV PHP_BIN_DIR $PHP_BUILD_DIR/bin
ENV PHP_CONFIG $PHP_BIN_DIR/php-config
ENV PHPIZE $PHP_BIN_DIR/phpize

ENV PHP_VERSION 7.0.33
ENV PHP_FILENAME php-$PHP_VERSION.tar.gz
ENV PHP_SHA256 d71a6ecb6b13dc53fed7532a7f8f949c4044806f067502f8fb6f9facbb40452a

# Download and extract PHP source code
RUN wget -O "${PHP_FILENAME}" "http://cn2.php.net/get/${PHP_FILENAME}/from/this/mirror" \
    && echo "${PHP_SHA256}  ${PHP_FILENAME}" | sha256sum -c - \
    && mkdir -p /usr/local/src/ \
    && tar -zxf "${PHP_FILENAME}" -C /usr/local/src/ \
    && rm -rf "${PHP_FILENAME}"


# Compile source Code
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
    --with-mhash \
    --with-mysqli \
    --with-xmlrpc \
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

RUN cd /usr/local/src/php-$PHP_VERSION \
    && make && make install

ENV EXTENSIONS \
    xdebug-2.7.2 \
    mongodb-1.5.5 \
    #pthreads-3.1.6 \
    redis-3.0.0
# Search in https://pecl.php.net/index.php get name
RUN for extension in ${EXTENSIONS}; do \
        cd /tmp \
        && wget -qO- "${extension}.tgz" "https://pecl.php.net/get/${extension}.tgz" | tar -zxvf - -C /tmp \
        && cd "${extension}" \
        && $PHPIZE \
        && ./configure --with-php-config=$PHP_CONFIG \
        && make && make install \
        && cd /tmp \
        && rm -rf "${extension}"; \
    done

# Configure PHP
RUN set -o pipefail && sed \
    -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' \
    /usr/local/src/php-$PHP_VERSION/php.ini-production > $PHP_CONF_DIR/php.ini

RUN set -o pipefail && sed \
    -e 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' \
    -e 's/;error_log = log\/php-fpm.log/error_log = log\/php-fpm.log/g' \
    -e 's/;daemonize = yes/daemonize = no/g' \
    $PHP_CONF_DIR/php-fpm.conf.default > $PHP_CONF_DIR/php-fpm.conf

RUN set -o pipefail && sed \
    -e 's/user = nobody/user = www-data/g' \
    -e 's/group = nobody/group = www-data/g' \
    -e 's/listen = 127.0.0.1:9000/listen = 9000/g' \
    # -e 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g' \
    # -e 's/;listen.owner = nobody/listen.owner = www-data/g' \
    # -e 's/;listen.group = nobody/listen.group = www-data/g' \
    # -e 's/;listen.mode = 0660/listen.mode = 0660/g' \
    -e 's/pm.max_children = 5/pm.max_children = 75/g' \
    -e 's/pm.start_servers = 2/pm.start_servers = 10/g' \
    -e 's/pm.min_spare_servers = 1/pm.min_spare_servers = 5/g' \
    -e 's/pm.max_spare_servers = 3/pm.max_spare_servers = 10/g' \
    -e 's/;pm.max_requests = 500/pm.max_requests = 500/g' \
    $PHP_CONF_SCAN_DIR/www.conf.default > $PHP_CONF_SCAN_DIR/www.conf

# Enable php extension
COPY xdebug.ini $PHP_CONF_SCAN_DIR/xdebug.ini
RUN echo "extension_dir = $($PHP_CONFIG --extension-dir)" >> $PHP_CONF_DIR/php.ini \
    && echo 'extension=redis.so' >> $PHP_CONF_DIR/php.ini \
    && echo 'extension=mongodb.so' >> $PHP_CONF_DIR/php.ini \
    # && echo 'extension=pthreads.so' >> $PHP_CONF_DIR/php.ini \
    && echo 'zend_extension=opcache.so' >> $PHP_CONF_DIR/php.ini

# Configure opcache
RUN set -o pipefail && sed -i \
    -e 's/;opcache.enable=0/opcache.enable=1/g' \
    -e 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' \
    -e 's/;opcache.file_cache=/opcache.file_cache=\/tmp/g' \
    -e 's/;opcache.huge_code_pages=1/opcache.huge_code_pages=1/g' \
    $PHP_CONF_DIR/php.ini

# Create the system startup command
RUN addgroup -S www-data && adduser -S www-data -G www-data
COPY php7.0-fpm /etc/init.d/php7.0-fpm
RUN chmod a+x /etc/init.d/php7.0-fpm

# Define binary directory
ENV PATH $PHP_BIN_DIR:$PATH

# Clean
RUN apk del $PHPIZE_DEPS
RUN rm -rf /tmp/* /var/cache/apk/* /var/tmp/*
RUN rm -rf /usr/local/src/php-$PHP_VERSION

# Define working directory
WORKDIR $PHP_BUILD_DIR

# Define default command
CMD ["/etc/init.d/php7.0-fpm", "start"]

# Expose Ports
EXPOSE 9000
