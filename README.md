# Kimai - OpenSource Time Tracking

See: http://www.kimai.org/

With separate MySQL Container.

Run:
        docker run --volume /etc/kimai --name kimai-volumes mysql true
        docker run -d -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) --name kimai-mysql mysql
        docker run -d --name kimai --link kimai-mysql:mysql -p 80:80 mwaeckerlin/kimai

Got to http://localhost and login with username `admin` and password `changeme`

Note: Don't forget to change the admin password!