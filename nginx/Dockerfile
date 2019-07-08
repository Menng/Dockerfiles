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

# Install Nginx.
RUN apk add --no-cache nginx && rm -rf /var/cache/apk/*
RUN adduser -S www-data -G www-data

# Configuration Nginx.
RUN mkdir /srv/www \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R root:www-data /srv/www \
    && mkdir -p /run/nginx/ \
    && rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY default /etc/nginx/conf.d/default.conf

# Define mountable directories.
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/srv/www"]

# Define working directory.
WORKDIR /srv/www

# Expose ports.
EXPOSE 80
EXPOSE 443

# Define default command.
STOPSIGNAL SIGTERM

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

