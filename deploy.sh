set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists php || ! php -v | grep -q "PHP 8.2"; then
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
    sudo apt install -y php8.2 php8.2-cli php8.2-fpm \
        php8.2-mbstring php8.2-xml php8.2-zip php8.2-curl php8.2-mysql unzip
    sudo update-alternatives --set php /usr/bin/php8.2
    echo "PHP 8.2 installed"
else
    echo "PHP 8.2 already available"
fi

if ! command_exists composer; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    echo "Composer installed successfully"
else
    echo "Composer already installed"
fi


if ! command_exists nginx; then
    sudo apt install -y nginx
    echo "Nginx installed"
else
    echo "Nginx already installed"
fi

sudo rm -f /etc/nginx/sites-enabled/*
sudo rm -f /etc/nginx/sites-available/laravel

# 2. Create fresh Laravel Nginx config
sudo tee /etc/nginx/sites-available/laravel >/dev/null <<EOF
server {
    listen 80;
    server_name _;
    root /home/ubuntu/laravel/public;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 3. Enable the new site
sudo ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel

# 4. Verify & reload
sudo nginx -t
sudo systemctl restart php8.2-fpm
sudo systemctl restart nginx
git config pull.rebase false 2>/dev/null || true

composer install --no-dev --optimize-autoloader --no-interaction

echo "Deployment setup completed successfully!"
