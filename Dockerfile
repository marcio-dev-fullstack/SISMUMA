FROM php:8.3-fpm-alpine AS base

# Instalação de dependências do sistema e ferramentas de compilação
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev \
    autoconf \
    g++ \
    make \
    linux-headers

# Configuração e instalação das extensões PHP essenciais
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        xml

# Instalação do Composer oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuração do diretório de trabalho dentro do container
WORKDIR /var/www

# Estágio de Desenvolvimento (com Xdebug opcional)
FROM base AS development
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps

COPY . /var/www
EXPOSE 9000
CMD ["php-fpm"]

# Estágio de Produção (limpo)
FROM base AS production
COPY . /var/www
EXPOSE 9000
CMD ["php-fpm"]