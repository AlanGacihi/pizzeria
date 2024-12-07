#!/bin/bash
# Make sure this file has executable permissions, run `chmod +x run-app.sh`

# Set up PHP configurations
echo "
memory_limit = 256M
max_execution_time = 300
upload_max_filesize = 64M
post_max_size = 64M
" > /usr/local/etc/php/conf.d/custom.ini

# Create necessary directories with proper permissions
mkdir -p storage/framework/views
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/logs
mkdir -p storage/app/pdf/cache
mkdir -p bootstrap/cache

# Set permissions for storage and cache directories
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chmod -R 775 storage/app/pdf/cache

# Set proper ownership
# Note: www-data is the typical web server user, adjust if different
chown -R www-data:www-data storage
chown -R www-data:www-data bootstrap/cache
chown -R www-data:www-data storage/app/pdf/cache

# Ensure Laravel logs are writable
touch storage/logs/laravel.log
chmod 664 storage/logs/laravel.log
chown www-data:www-data storage/logs/laravel.log

# Clear existing caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear

# Your existing commands
php artisan migrate:fresh --force && \
php artisan db:seed --force && \
node /assets/scripts/prestart.mjs /assets/nginx.template.conf /nginx.conf && \
(php-fpm -y /assets/php-fpm.conf & nginx -c /nginx.conf)

# Optional: Add error checking
if [ $? -ne 0 ]; then
    echo "Error: Application startup failed"
    exit 1
fi

# Keep the script running (if needed)
tail -f storage/logs/laravel.log
