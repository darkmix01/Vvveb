FROM php:8.3-fpm

# Instalar dependencias del sistema, Nginx y Supervisor
RUN apt-get update && apt-get install -y --no-install-recommends \
      nginx \
      supervisor \
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

# Configurar Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Configurar Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copiar código de la aplicación
WORKDIR /var/www/html
COPY . .

# Exponer puerto HTTP (Railway usa la variable PORT)
EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
