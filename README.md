# Kimai - OpenSource Time Tracking

See: http://www.kimai.org/

With separate MySQL Container.

Run:
```
        docker run -d --restart unless-stopped --volume /etc/kimai --name kimai-volumes mysql sleep infinity
        docker run -d --restart unless-stopped -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) --name kimai-mysql --volumes-from kimai-volumes mysql
        docker run -d --restart unless-stopped --name kimai --link kimai-mysql:mysql --volumes-from kimai-volumes -p 80:80 mwaeckerlin/kimai
```

Got to http://localhost and login with username `admin` and password `changeme`

Note: Don't forget to change the admin password!

# Build

```
docker build --rm -t mwaeckerlin/kimai .
```


