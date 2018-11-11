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
RUN apt-get update -y
RUN apt-get upgrade -y

# Install MySQL.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
    rm -rf /var/lib/apt/lists/*

# Config MySQL
RUN \
    sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
    sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
    echo "mysqld_safe &" > /tmp/config && \
    echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
    echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
    echo "mysql -e 'UPDATE mysql.user SET Password=PASSWORD(\"123456\") WHERE user=\"root\"; FLUSH PRIVILEGES;'" >> /tmp/config && \
    bash /tmp/config && \
    rm -f /tmp/config
RUN echo '[mysqld]\nbind-address=0.0.0.0\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["mysqld_safe"]

# Expose ports.
EXPOSE 3306
