#!/bin/bash
set -e

echo "--- Aplicando permisos de Laravel ---"
# Dar propiedad a www-data y permisos 775 a todo el proyecto
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html
echo "--- Permisos Aplicados ---"

exec "$@"
