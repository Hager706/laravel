#!/bin/bash
set -e

# git pull origin 12.x
sudo apt update
sudo apt install -y php php-cli php-mbstring php-xml php-zip unzip
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
composer install --no-dev --optimize-autoloader

# Run migrations (assumes .env is configured with RDS details)
php artisan migrate --force
