FROM debian:jessie

# Set timezone
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Set DNS Server
RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf
RUN echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# Replace source list
RUN sed -i -e "s/\(deb\|security\).debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list

# Upgrade System
RUN apt-get update -y
RUN apt-get upgrade -y

# Install Nginx.
RUN apt-get install -y vim nginx --no-install-recommends
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
RUN chown -R www-data:www-data /var/lib/nginx
ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/usr/share/nginx/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["service","nginx","start"]

# Expose ports.
EXPOSE 80
EXPOSE 443
# End Nginx

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

