#!/bin/bash
set -e

# Update system and install PHP 8.2 + MySQL extension
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php8.2 php8.2-cli php8.2-mbstring php8.2-xml php8.2-zip php8.2-curl php8.2-mysql unzip

# Ensure PHP 8.2 is default
sudo update-alternatives --set php /usr/bin/php8.2

# Install Composer if not present
if ! command -v composer &> /dev/null; then
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi
# git config pull.rebase false

echo "Pull latest code..."
git stash push -m "auto-stash" || true
git pull origin 12.x --rebase --strategy-option theirs
git stash pop || true

# Install/update dependencies
/usr/local/bin/composer install --no-dev --optimize-autoloader

# Run migrations (.env is already populated by workflow)
php artisan migrate --force
