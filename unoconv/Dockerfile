ARG FROM
FROM $FROM

USER root

RUN mkdir -p /usr/share/man/man1 && apt-get update \
#
# Install some imaging tools
#
    && apt-get install -y imagemagick poppler-utils exiftool \
#
# Install unoconv ...
#
    && apt-get install -y unoconv \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

USER ${APACHE_RUN_USER}
