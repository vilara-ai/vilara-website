# Use PHP 8.2 with Apache
FROM php:8.2-apache

# Install PostgreSQL client and PHP extensions
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache
RUN echo '<Directory /var/www/html>' > /etc/apache2/conf-available/custom.conf && \
    echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/custom.conf && \
    echo '    AllowOverride All' >> /etc/apache2/conf-available/custom.conf && \
    echo '    Require all granted' >> /etc/apache2/conf-available/custom.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/custom.conf && \
    a2enconf custom

# Set Apache to listen on port 8080 (Cloud Run requirement)
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# Copy website files
COPY . /var/www/html/

# Create .htaccess for URL routing
RUN echo 'RewriteEngine On' > /var/www/html/.htaccess && \
    echo 'RewriteCond %{REQUEST_FILENAME} !-f' >> /var/www/html/.htaccess && \
    echo 'RewriteCond %{REQUEST_FILENAME} !-d' >> /var/www/html/.htaccess && \
    echo 'RewriteRule ^api/(.*)$ /api/$1 [L,QSA]' >> /var/www/html/.htaccess && \
    echo '' >> /var/www/html/.htaccess && \
    echo '# CORS Headers' >> /var/www/html/.htaccess && \
    echo 'Header set Access-Control-Allow-Origin "*"' >> /var/www/html/.htaccess && \
    echo 'Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"' >> /var/www/html/.htaccess && \
    echo 'Header set Access-Control-Allow-Headers "Content-Type"' >> /var/www/html/.htaccess

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Configure PHP
RUN echo "display_errors = Off" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "log_errors = On" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "error_log = /dev/stderr" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize = 10M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size = 10M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/custom.ini

# Health check endpoint
RUN echo '<?php echo json_encode(["status" => "healthy"]); ?>' > /var/www/html/health.php

# Expose port 8080
EXPOSE 8080

# Start Apache
CMD ["apache2-foreground"]