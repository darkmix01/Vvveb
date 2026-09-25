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

# Copiar configs (nombres reales de tu repo)
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini ${PHP_INI_DIR}/php.ini

WORKDIR /var/www/html
COPY . .

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]