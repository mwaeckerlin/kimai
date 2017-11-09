#!/bin/bash -ex

if [ -z "${MYSQL_ENV_MYSQL_ROOT_PASSWORD}" -o \
     -z "${MYSQL_PORT_3306_TCP_ADDR}" -o \
     -z "${MYSQL_PORT_3306_TCP_PORT}" ]; then
    echo "You must link to a MY SQL container with --link <container>:mysql" \
        1>&2
    exit 1
fi

# wait for mysql to become ready
mysqlstatus=0
for ((i=0; i<300; ++i)); do
    if nmap -p ${MYSQL_PORT_3306_TCP_PORT} ${MYSQL_PORT_3306_TCP_ADDR} \
            | grep -q ${MYSQL_PORT_3306_TCP_PORT}'/tcp open'; then
        mysqlstatus=1
        break;
    fi
    sleep 1
done
test $mysqlstatus -eq 1

if ! test -e /etc/kimai/autoconf.php; then
    MYSQL_PASSWD=${MYSQL_PASSWD:-$(pwgen -s 16 1)}
    cat > /etc/kimai/autoconf.php <<EOF
<?php
\$server_hostname = "mysql";
\$server_database = "kimai";
\$server_username = "kimai";
\$server_password = "${MYSQL_PASSWD}";
\$server_conn     = "mysql";
\$server_type     = "";
\$server_prefix   = "kimai_";
\$language        = "de";
\$password_salt   = "$(pwgen -s 21 1)";
?>
EOF
    chown -R www-data.www-data /etc/kimai
    ! test -e ${KIMAI_ROOT}/includes/autoconf.php || \
        rm ${KIMAI_ROOT}/includes/autoconf.php
    ln -s /etc/kimai/autoconf.php ${KIMAI_ROOT}/includes/autoconf.php
    echo "**** Setup Database (first run)"
    mysql -u root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -h mysql -e "create database kimai default character set utf8 collate utf8_bin"
    mysql -u root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -h mysql -e "grant all privileges on *.* to kimai@'%' identified by '${MYSQL_PASSWD}'"
else
    MYSQL_PASSWD=$(sed -n 's, *\$server_password = "\(.*\)";.*,\1,p' /etc/kimai/autoconf.php)
fi
test -d /run/php || mkdir -p /run/php
if test -d ${KIMAI_ROOT}/installer; then
    chown -R www-data.www-data ${KIMAI_ROOT}
    php-fpm7.0
    nginx &
    sleep 2
    wget -O- http://localhost/installer/install.php?accept=1
    rm -r ${KIMAI_ROOT}/installer
    pkill nginx
    pkill php-fpm
    echo "Kimai Configuration Parameter:"
    echo " → host: mysql, user: kimai, password: ${MYSQL_PASSWD}, table: kimai"
fi

php-fpm7.0 && nginx
