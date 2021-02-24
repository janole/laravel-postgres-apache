ARG FROM
FROM $FROM

USER root

RUN true \
#
# Update package list
#
    && apt-get update \
#
# Install xdebug
#
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

# The xdebug.ini contains mostly ENV vars for easy overriding
COPY ./xdebug.ini $PHP_INI_DIR/conf.d/zzzz-xdebug.ini

# Default settings for xdebug
ENV XDEBUG_MODE="debug"
# Try to connect to host (this will work with Docker for Mac/Windows only.)
# See https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds
# See https://docs.docker.com/docker-for-windows/networking/#use-cases-and-workarounds
# See https://github.com/qoomon/docker-host for Linux
ENV XDEBUG_CLIENT_HOST="host.docker.internal"
ENV XDEBUG_CLIENT_PORT=9003
ENV XDEBUG_START_WITH_REQUEST="yes"

#
USER ${APACHE_RUN_USER}
