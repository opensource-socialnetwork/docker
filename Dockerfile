FROM php:8.4-apache

# Suppress interactive prompts during build
ARG DEBIAN_FRONTEND=noninteractive

# Pre-seed Postfix debconf answers so it installs silently
RUN echo "postfix postfix/mailname string localhost" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

# Install required packages and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    zip \
    nano \
    postfix \
    mailutils \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli zip mbstring pdo_mysql opcache exif \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable EXIF and Apache rewrite module
RUN docker-php-ext-enable exif && a2enmod rewrite

# Route PHP mail calls to internal Postfix sendmail
RUN echo "sendmail_path = /usr/sbin/sendmail -t -i" > /usr/local/etc/php/conf.d/sendmail.ini

# Download and extract OSSN
ADD https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip /tmp/ossn.zip
RUN unzip /tmp/ossn.zip -d /var/www/html/ \
    && mv /var/www/html/ossn/* /var/www/html/ \
    && rm -rf /var/www/html/ossn /tmp/ossn.zip

# Fetch latest settings template
RUN curl -L -o /var/www/html/installation/pages/settings.php https://raw.githubusercontent.com/opensource-socialnetwork/docker/refs/heads/main/settings.php

# Create data directory and permissions
RUN mkdir -p /var/www/ossn_data && \
    chown -R www-data:www-data /var/www/ossn_data && \
    chgrp www-data /var/www/ossn_data && \
    chmod g+w /var/www/ossn_data && \
    chown -R www-data:www-data /var/www/html/ && \
    chmod -R 755 /var/www/html/

EXPOSE 80

# Start Postfix service before launching Apache
CMD ["sh", "-c", "service postfix start && apache2-foreground"]
