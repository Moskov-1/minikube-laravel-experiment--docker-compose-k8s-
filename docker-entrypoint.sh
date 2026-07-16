#!/bin/sh
set -e

if [ "$APP_ENV" = "production" ]; then
    echo "Caching configuration for production..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
else
    echo "Running in $APP_ENV mode. Clearing cache..."
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
fi

# 2. Run migrations (Optional: usually better handled in CI/CD or as a separate task, 
# but for simple setups it can be done here. Be careful with auto-scaling!)
# php artisan migrate --force

# 3. Execute the container's main command (e.g., apache2-foreground)
echo "Starting application..."
exec "$@"
