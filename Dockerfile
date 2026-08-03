# =========================
# Stage 1: Frontend Build
# =========================
FROM node:20-alpine AS node-builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY resources ./resources
COPY public ./public/
COPY vite.config.js ./

RUN npm run build


# =========================
# Stage 2: Composer Build
# =========================
FROM composer:2 AS composer-builder

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    # --no-dev \
    --no-interaction \
    --no-ansi \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --ignore-platform-reqs


# =========================
# Stage 3: Runtime
# =========================
FROM php:8.4-fpm-alpine as runtime

WORKDIR /app

# Runtime libraries
RUN apk add --no-cache \
    postgresql-client \
    mariadb-client \
    bash \
    libpng \
    libjpeg-turbo \
    freetype \
    libzip

# Build dependencies
RUN apk add --no-cache --virtual .build-deps \
    postgresql-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    gettext-dev \
    $PHPIZE_DEPS \
    && docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    exif \
    pcntl \
    bcmath \
    gd \
    opcache \
    # gettext \
    mbstring \
    zip \
    && apk del .build-deps

# Copy application
COPY . .

# Copy frontend assets
COPY --from=node-builder /app/public/build ./public/build

# Copy vendor folder
COPY --from=composer-builder /app/vendor ./vendor

# Required Laravel directories
# RUN mkdir -p \
#     storage/logs \
#     storage/framework/cache \
#     storage/framework/sessions \
#     storage/framework/views \
#     bootstrap/cache

# Permissions
RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache \
    public/avatars \
    public/banners \
    public/uploads \
    public/settings \
    public/public_uploads


USER www-data

EXPOSE 8080

# CMD ["php-fpm", "-F"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
