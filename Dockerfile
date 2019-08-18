FROM alpine:latest

# update index
RUN apk update

# install tools
RUN apk add wget

# install nginx and php
RUN apk add nginx php7 php7-common php7-mbstring php7-session php7-json php7-fpm

# Download and install Dokuwiki
RUN wget -q https://github.com/splitbrain/dokuwiki/archive/release_stable_2018-04-22b.tar.gz -P /tmp \
    && mkdir /var/www/dokuwiki \
    && tar -xzf /tmp/release_stable_2018-04-22b.tar.gz -C /var/www/dokuwiki --strip-components 1

# Make dokuwiki accessible to nginx
RUN chown -R nginx:nginx /var/www/dokuwiki \
    && chmod -R 777 /var/www/dokuwiki

# Install nginx config
COPY nginx/sites/default /etc/nginx/conf.d/default.conf

# Nginx files
RUN mkdir /run/nginx/ && touch /run/nginx/nginx.pid
RUN touch /var/log/nginx/access.log && touch /var/log/nginx/error.log

COPY entrypoint.sh /entrypoint.sh

EXPOSE 80
VOLUME /var/www/dokuwiki/

CMD ["sh", "/entrypoint.sh"]
