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

# Defining ENV variables
ENV MYSQL_ROOT_PASSWORD 123456
ENV DB_DATA_PATH /var/lib/mysql

# Install MySQL.
RUN apk add --update --no-cache mariadb mariadb-client && rm -rf /var/cache/apk/*
RUN addgroup mysql mysql

# Define working directory.
WORKDIR /

# Copy of the MySQL startup script.
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

# Define mountable directories.
VOLUME ["/var/lib/mysql"]

# Expose ports.
EXPOSE 3306

# Entrypoint scripts.
ENTRYPOINT ["/entrypoint.sh"]
