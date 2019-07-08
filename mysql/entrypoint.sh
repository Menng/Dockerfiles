#!/bin/sh
#
# A simple shell script to start up MySQL with Docker.

set -e

TABLE_MYSQL_DATA_PATH="${DB_DATA_PATH}/mysql"

if [[ ! -d "/run/mysqld" ]]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

if [[ -d "${TABLE_MYSQL_DATA_PATH}" ]]; then
	echo '[i] MySQL directory already exist, skipping creation.'
else
	echo "[i] MySQL data directory not found, creating initial DB."

	# init database
	echo 'Initializing database'
	mysql_install_db --user=mysql --datadir="${DB_DATA_PATH}" > /dev/null
	echo 'Database initialized'

	echo "[i] MySQL root password: $MYSQL_ROOT_PASSWORD"

	# create temp file
	tmpfile=`mktemp`
	if [[ ! -f "${tmpfile}" ]]; then
	    return 1
	fi

	# save sql
	echo "[i] Create temp file: ${tmpfile}"
	cat << EOF > $tmpfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

	# run sql in tempfile
	echo "[i] run tempfile: ${tmpfile}"
	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < ${tmpfile}
	rm -f ${tmpfile}
fi

# Enable remote networking
sed -i "s/skip-networking/#skip-networking/g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s/#bind-address/bind-address/g" /etc/my.cnf.d/mariadb-server.cnf

echo "[i] Sleeping 3 sec"
sleep 3

echo "Starting all process"
exec /usr/bin/mysqld --user=mysql --console --skip-host-cache
