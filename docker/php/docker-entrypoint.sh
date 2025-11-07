#!/bin/bash
set -e 

# La única lógica necesaria en runtime que no está resuelta por la imagen base
echo "--- Aplicando permisos de Laravel (Storage/Cache) ---"
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
echo "--- Permisos Aplicados ---"

# Ejecuta el CMD que se le pasó (e.g., php-fpm)
exec "$@"