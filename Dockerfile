# Updated base image to PHP 8.4 Apache
FROM php:8.4-apache

# Prevent apt-get interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
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

# Enable EXIF for PHP
RUN docker-php-ext-enable exif

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# 3. Configure PHP sendmail path to use local Postfix binary
RUN echo "sendmail_path = /usr/sbin/sendmail -t -i" > /usr/local/etc/php/conf.d/sendmail.ini

# Download and extract OSSN
ADD https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip /tmp/ossn.zip
RUN unzip /tmp/ossn.zip -d /var/www/html/ \
    && mv /var/www/html/ossn/* /var/www/html/ \
    && rm -rf /var/www/html/ossn /tmp/ossn.zip

# Replace settings.php with the latest from GitHub
RUN curl -L -o /var/www/html/installation/pages/settings.php https://raw.githubusercontent.com/opensource-socialnetwork/docker/refs/heads/main/settings.php

# Create a data directory for OSSN (used for file storage)
RUN mkdir -p /var/www/ossn_data && \
    chown -R www-data:www-data /var/www/ossn_data

# Set permissions and group ownership for the OSSN parent directory
RUN chgrp www-data /var/www/ossn_data && \
    chmod g+w /var/www/ossn_data

# Set permissions for the web directory
RUN chown -R www-data:www-data /var/www/html/ && \
    chmod -R 755 /var/www/html/

# Expose port 80
EXPOSE 80

# 4. Start postfix service, then start Apache in the foreground
CMD ["sh", "-c", "service postfix start && apache2-foreground"]

