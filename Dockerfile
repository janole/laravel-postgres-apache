FROM php:7.3-apache

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

ENV APACHE_DOCUMENT_ROOT /app/public

RUN	true \
#
# Update package list and update packages
#
	&& apt-get update \
    && apt-get dist-upgrade -y \
#
# Install all necessary PHP mods
#
	&& apt-get install -y libxml2-dev zlib1g-dev libpq-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxpm-dev libwebp-dev libsodium-dev libgmp-dev libzip-dev \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-xpm-dir=/usr/incude/ --with-webp-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-install xml pgsql pdo_pgsql zip gmp intl opcache \
#
# Use the default PHP production configuration
#
	&& mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
    && true

RUN true \
#
# Install all other tools
#
	&& apt-get install -y socat localehelper msmtp msmtp-mta vim \
#
# Prepare folder structure ...
#
   	&& mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views \
	&& chown -R www-data:www-data /app \
#
# Setup apache
#
    && echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf \
    && a2enmod rewrite actions fqdn \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
#
# Clean-up
#
	&& rm -rf /var/lib/apt/lists/*

#
# Copy our custom configs
#
COPY ./configs /

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Disable warning for running composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Configure OPCACHE
ENV OPCACHE_ENABLE=1
ENV OPCACHE_VALIDATE_TIMESTAMPS=1
ENV OPCACHE_REVALIDATE_FREQ=2
ENV OPCACHE_FILE_CACHE=""

#
CMD ["bash", "-c", "/container-startup.sh && exec apache2-foreground"]
