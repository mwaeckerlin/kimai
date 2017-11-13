FROM mwaeckerlin/ubuntu-base
MAINTAINER mwaeckerlin

# build downloads latest kimai unless link is set to a release, such as:
# ENV KIMAI_LINK "https://github.com/kimai/kimai/releases/download/0.9.3/kimai_0.9.3.zip"
ENV KIMAI_LINK ""
ENV KIMAI_ROOT /var/www/kimai
#/{compile,extensions/ki_timesheets/compile,extensions/ki_adminpanel/compile,extensions/ki_expenses/compile,extensions/ki_export/compile,extensions/ki_budget/compile,extensions/ki_invoice/compile,temporary,includes/autoconf.php}

WORKDIR /tmp
RUN apt-get update -y && apt-get install -y wget unzip nginx-full php-xml php-fpm php-mysql php-ldap mysql-client pwgen nmap
RUN if test -n "${KIMAI_LINK}"; then wget -qO /tmp/kimai.zip "${KIMAI_LINK}"; fi
RUN if test -z "${KIMAI_LINK}"; then wget -qO /tmp/kimai.zip https://github.com$(wget -qO- https://github.com/kimai/kimai/releases/latest | sed -n 's,.*<a href="\([^"]*kimai_[^"]*\.zip\)".*,\1,p'); fi
RUN mkdir -p ${KIMAI_ROOT}
RUN unzip /tmp/kimai.zip -d ${KIMAI_ROOT}
RUN chown -R www-data.www-data ${KIMAI_ROOT}
RUN rm /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
ADD kimai.conf /etc/nginx/sites-available/kimai.conf
RUN ln -s /etc/nginx/sites-available/kimai.conf /etc/nginx/sites-enabled/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80
VOLUME /etc/kimai
ADD start.sh /start.sh
CMD /start.sh
