FROM ubuntu:14.04

MAINTAINER Menng

# Set timezone
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Set DNS Server
RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf
RUN echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# Replace source list
RUN sed -i -e "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

# Upgrade System
RUN apt-get update -y
RUN apt-get upgrade -y

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
    patch \
    wget \
    --no-install-recommends

# Install Requirements
RUN apt-get -y install libtool libmcrypt-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev \
		libmhash-dev libxslt1-dev libxpm-dev libbz2-dev libgd2-xpm-dev libssl-dev libcurl4-openssl-dev \
		libtidy-dev libltdl-dev libmhash2 libmysqlclient-dev --no-install-recommends

# Create Link Symbol
RUN ln -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/libXpm.a
RUN mkdir /usr/include/freetype2/freetype
RUN ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

# Download PHP Source code
RUN cd /tmp && \
wget http://museum.php.net/php5/php-5.3.10.tar.gz && \
tar zxvf php-5.3.10.tar.gz

# Compile Source Code
RUN cd /tmp/php-5.3.10 && \
		./configure \
		--prefix=/usr/local/php5 \
		--with-config-file-scan-dir=/usr/local/php5/etc \
		--with-config-file-path=/usr/local/php5/etc \
		--with-mysql=mysqlnd \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--with-mysql-sock \
		--with-gd \
		--with-zlib \
		--with-xsl \
		--with-bz2 \
		--with-curl \
		--with-tidy \
		--with-iconv \
		--with-xmlrpc \
		--with-gettext \
		--with-mcrypt \
		--with-mhash \
		--with-openssl \
		--with-pcre-regex \
		--with-curlwrappers \
		--with-png-dir=/usr/lib \
		--with-jpeg-dir=/usr/lib \
		--with-freetype-dir=/usr/lib \
		--enable-inline-optimization \
		--enable-maintainer-zts \
		--enable-gd-native-ttf \
		--enable-magic-quotes \
		--enable-mbstring \
		--enable-mbregex \
		--enable-sysvsem \
		--enable-sysvshm \
		--enable-bcmath \
		--enable-sockets \
		--enable-session \
		--enable-shmop \
		--enable-pcntl \
		--enable-soap \
		--enable-fpm \
		--enable-xml \
		--enable-exif \
		--enable-ftp \
		--enable-zip \
		--enable-debug \
		--disable-rpath \
		--without-pear

COPY php-5.3.10-*.patch /tmp/
RUN cd /tmp/php-5.3.10 && \
		# wget -O php-5.3.10.patch https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt && \
		patch -p0 -b < /tmp/php-5.3.10-libxml2.patch

RUN cd /tmp/php-5.3.10 && \
		make && make install

RUN cd /tmp/ && \
		wget https://xdebug.org/files/xdebug-2.2.0.tgz && \
		tar zxvf xdebug-2.2.0.tgz && \
		cd xdebug-2.2.0 && \
		/usr/local/php5/bin/phpize && \
		./configure --with-php-config=/usr/local/php5/bin/php-config && \
		make && make install

# Configure PHP
RUN cp /tmp/php-5.3.10/php.ini-production /usr/local/php5/etc/php.ini
RUN cp /tmp/php-5.3.10/sapi/fpm/php-fpm /usr/local/php5/bin
RUN cp /usr/local/php5/etc/php-fpm.conf.default /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/;error_log = log\/php-fpm.log/error_log = log\/php-fpm.log/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/user = nobody/user = www-data/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/group = nobody/group = www-data/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/listen = 127.0.0.1:9000/listen = 9000/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/;daemonize = yes/daemonize = no/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/pm.max_children = 5/pm.max_children = 75/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/pm.start_servers = 2/pm.start_servers = 10/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = 5/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 10/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/;pm.max_requests = 500/pm.max_requests = 500/g" /usr/local/php5/etc/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /usr/local/php5/etc/php.ini
RUN echo 'extension_dir = "/usr/local/php5/lib/php/extensions/debug-zts-20090626"' >> /usr/local/php5/etc/php.ini

# Create the system startup command
ADD php5.3-fpm /etc/init.d/php5.3-fpm
ADD xdebug.ini /usr/local/php5/etc/xdebug.ini
RUN chmod 755 /etc/init.d/php5.3-fpm
RUN update-rc.d php5.3-fpm defaults

# Clean
RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove -y

# Define working directory
WORKDIR /usr/local/php5

# Define default command
CMD ["service","php5.3-fpm","start"]

# Expose Ports
EXPOSE 9000
