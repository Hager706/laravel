# #!/bin/bash
# set -e

# # Update system and install PHP 8.2 + MySQL extension
# sudo apt update
# sudo apt install -y software-properties-common
# sudo add-apt-repository -y ppa:ondrej/php
# sudo apt update
# sudo apt install -y php8.2 php8.2-cli php8.2-mbstring php8.2-xml php8.2-zip php8.2-curl php8.2-mysql unzip

# # Ensure PHP 8.2 is default
# sudo update-alternatives --set php /usr/bin/php8.2

# # Install Composer if not present
# if ! command -v composer &> /dev/null; then
#   curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# fi

# # Configure Git to merge on pull
# git config pull.rebase false

# echo "Pull latest code..."
# git stash push -m "auto-stash" || true
# git pull origin 12.x
# git stash pop || true

# # Install/update dependencies
# /usr/local/bin/composer install --no-dev --optimize-autoloader

# # Run migrations (.env is already populated by workflow)
# php artisan migrate --force
#!/bin/bash
set -e

echo "🔧 Starting Laravel deployment setup..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install PHP 8.2 only if not already installed
if ! command_exists php || ! php -v | grep -q "PHP 8.2"; then
    echo "📦 Installing PHP 8.2..."
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
    sudo apt install -y \
        php8.2 \
        php8.2-cli \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        php8.2-curl \
        php8.2-mysql \
        unzip

    # Set PHP 8.2 as default
    sudo update-alternatives --set php /usr/bin/php8.2
    echo "✅ PHP 8.2 installed successfully"
else
    echo "✅ PHP 8.2 already installed"
fi

# Install Composer if not present
if ! command_exists composer; then
    echo "📦 Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    echo "✅ Composer installed successfully"
else
    echo "✅ Composer already installed"
fi

# Configure Git (only once)
git config pull.rebase false 2>/dev/null || true

# Install/Update Composer dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# Generate app key if not exists
if ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    echo "🔑 Generating application key..."
    php artisan key:generate --force
fi

# Create storage directories if they don't exist
echo "📁 Creating storage directories..."
mkdir -p storage/framework/{sessions,views,cache}
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Set proper permissions
echo "🔒 Setting permissions..."
chmod -R 775 storage bootstrap/cache

echo "✅ Deployment setup completed successfully!"
