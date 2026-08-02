# ==========================================
# ESTÁGIO 1: Base (PHP com extensões)
# ==========================================
FROM php:8.3-fpm-alpine AS base

# Instala as dependências de compilação necessárias para as extensões PHP
RUN apk add --no-cache \
    build-base \
    libzip-dev \
    oniguruma-dev \
    postgresql-dev \
    gd-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev

# Configura e instala extensões do PHP requeridas pelo Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql pgsql bcmath pcntl zip gd

# Limpa os pacotes de compilação para manter a imagem base enxuta
RUN apk del build-base

# ==========================================
# ESTÁGIO 2: Desenvolvimento (Development)
# ==========================================
FROM base AS development
WORKDIR /var/www/html

# Instala dependências de desenvolvimento (git, curl, etc.) e o Xdebug
RUN apk add --no-cache git curl unzip postgresql-libs \
    && pecl install xdebug && docker-php-ext-enable xdebug

WORKDIR /var/www/html

# Copia o executável do Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cria um usuário não-root para executar a aplicação
RUN addgroup -g 1000 -S laravel && adduser -u 1000 -S laravel -G laravel
USER laravel

COPY --chown=laravel:laravel . .

# ==========================================
# ESTÁGIO 3: Construtor de Produção (Builder)
# ==========================================
FROM base AS builder
WORKDIR /var/www/html

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia apenas os arquivos do Composer para aproveitar o cache do Docker
COPY composer.json composer.lock ./

# Instala as dependências do Composer para produção
RUN composer install --no-interaction --no-progress --no-dev --optimize-autoloader
COPY . .
# ==========================================
# ESTÁGIO 4: Produção (Final)
# ==========================================
FROM base AS production
WORKDIR /var/www/html

# Instala apenas as dependências de execução, limpa o cache e cria o usuário em uma única camada
RUN apk add --no-cache nginx supervisor postgresql-libs \
    && adduser -u 82 -S -G www-data www-data

# Copia os arquivos do projeto vindos do construtor com as permissões corretas
# Graças ao .dockerignore, esta cópia não inclui mais arquivos de desenvolvimento.
COPY --from=builder --chown=www-data:www-data /var/www/html .

# Copia as configurações do Nginx e Supervisor de forma condicional se existirem, ou cria estruturas básicas
COPY docker/nginx.conf* /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf* /etc/supervisor/conf.d/supervisord.conf
COPY docker/start-production.sh* /usr/local/bin/start.sh

# Garante permissões de escrita para pastas de armazenamento e logs do Laravel
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && if [ -f /usr/local/bin/start.sh ]; then chmod +x /usr/local/bin/start.sh; fi

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]