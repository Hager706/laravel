#!/bin/bash
set -e

git pull origin 12.x

# Install/update dependencies
/usr/local/bin/composer install --no-dev --optimize-autoloader

# Run migrations (assumes .env is configured with RDS details)
php artisan migrate --force
