FROM php:8.3-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
      nginx \
      supervisor \
      gettext-base \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libxml2-dev \
      libwebp-dev \
      libpng-dev \
      libzip-dev \
      libonig-dev \
      libcurl4-openssl-dev \
      libicu-dev \
  && docker-php-ext-configure gd --with-webp --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd xml dom curl mbstring intl gettext zip mysqli \
  && pecl bundle -d /usr/src/php/ext apcu \
  && docker-php-ext-install /usr/src/php/ext/apcu \
  && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/html
COPY . .

RUN chown -R www-data:www-data /var/www/html \
 && find /var/www/html -type d -exec chmod 755 {} \; \
 && find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]