# ------------------------------
# Etapa de desarrollo
# ------------------------------
FROM php:8.3-fpm AS development

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev libpq-dev \
    && docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]

# ------------------------------
# Etapa de producción
# ------------------------------
FROM development AS production

WORKDIR /var/www/html

# Copiar composer.json y lock para instalar dependencias sin dev
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copiar el resto del código
COPY . .

# Instalar dependencias JS y compilar assets
RUN npm ci && npm run build

# Opcional: limpiar dev-tools
RUN apt-get purge -y git unzip curl && apt-get autoremove -y

ENV APP_ENV=production
ENV APP_DEBUG=false
