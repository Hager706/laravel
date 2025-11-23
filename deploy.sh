#
#!/bin/bash
# Run this ONCE when setting up a new EC2 server
# sudo bash setup-server.sh

set -e

echo "🔧 Setting up server environment..."

# Update system
apt update
apt upgrade -y

# Install software-properties-common
apt install -y software-properties-common

# Add PHP repository
add-apt-repository -y ppa:ondrej/php
apt update

# Install PHP 8.2 and extensions
apt install -y \
  php8.2 \
  php8.2-cli \
  php8.2-fpm \
  php8.2-mbstring \
  php8.2-xml \
  php8.2-zip \
  php8.2-curl \
  php8.2-mysql \
  php8.2-gd \
  php8.2-bcmath \
  unzip \
  git \
  nginx

# Set PHP 8.2 as default
update-alternatives --set php /usr/bin/php8.2

# Install Composer
if ! command -v composer &> /dev/null; then
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
  echo "✅ Composer installed"
fi

# Configure Git
git config --global pull.rebase false

echo "✅ Server setup completed!"
echo "Now you can run deployments from GitHub Actions"
