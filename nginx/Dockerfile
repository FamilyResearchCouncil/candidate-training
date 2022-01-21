FROM nginx

ARG WWWUSER=1100
ARG WWWGROUP=1100
WORKDIR /var/www/html

COPY ./nginx.conf /etc/nginx/templates/default.conf.template

RUN mkdir /var/www -p \
    && apt update \
    && apt install -y iputils-ping \
    && groupmod -g "$WWWGROUP" nginx \
    && usermod -u "$WWWUSER" nginx \
    && chown -R $WWWUSER:$WWWGROUP \
        /var/cache/nginx/ \
        /etc/nginx/ \
        /var/www/ \
        /run/
