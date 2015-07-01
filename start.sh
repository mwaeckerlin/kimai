#!/bin/bash -ex

if [ -z "${MYSQL_ENV_MYSQL_ROOT_PASSWORD}" -o \
     -z "${MYSQL_PORT_3306_TCP_ADDR}" -o \
     -z "${MYSQL_PORT_3306_TCP_PORT}" ]; then
    echo "You must link to a MY SQL container with --link <container>:mysql" \
        1>&2
    exit 1
fi

# wait for mysql to become ready
for ((i=0; i<20; ++i)); do
    if nmap -p ${MYSQL_PORT_3306_TCP_PORT} ${MYSQL_PORT_3306_TCP_ADDR} \
        | grep -q ${MYSQL_PORT_3306_TCP_PORT}'/tcp open'; then
        break;
    fi
    sleep 1
done

if ! mysqlshow -u root --password=${SQL_ENV_MYSQL_ROOT_PASSWORD} -h sql kimai; then
    echo "**** Setup Database (first run)"
    MY_SQL_PASSWD=$(pwgen -s 16 1)
    mysql -u root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -h mysql -e "create database kimai default character set utf8 collate utf8_bin"
    mysql -u root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -h mysql -e "grant all privileges on *.* to kimai@'%' identified by '${MY_SQL_PASSWD}'"
fi
if test -d ${KIMAI_ROOT}/installer; then
    rm ${KIMAI_ROOT}/includes/autoconf.php
    cat > /etc/kimai/autoconf.php <<EOF
<?php
\$server_hostname = "mysql";
\$server_database = "kimai";
\$server_username = "kimai";
\$server_password = "${MY_SQL_PASSWD}";
\$server_conn     = "mysql";
\$server_type     = "";
\$server_prefix   = "kimai_";
\$language        = "de";
\$password_salt   = "$(pwgen -s 21 1)";
?>
EOF
    ln -s /etc/kimai/autoconf.php ${KIMAI_ROOT}/includes/autoconf.php
    service php5-fpm start
    nginx &
    sleep 2
    wget -O- http://localhost/installer/install.php?accept=1
    rm -r ${KIMAI_ROOT}/installer
    pkill nginx
    service php5-fpm stop
    echo "Kimai Configuration Parameter:"
    echo " → host: mysql, user: kimai, password: ${MY_SQL_PASSWD}, table: kimai"
fi

service php5-fpm start && nginx
