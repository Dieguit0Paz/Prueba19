#!/bin/bash
set -e

# Activar entorno virtual
source /opt/odoo/app/venv/bin/activate

# Asegurar que DB_PORT tenga un valor numérico
export DB_PORT="${DB_PORT:-5432}"

# Renderizar el archivo de configuración con variables de entorno
envsubst < /opt/odoo/app/odoo.conf > /opt/odoo/app/rendered.conf

# Esperar a que el servicio PostgreSQL esté disponible
echo "Esperando que PostgreSQL esté activo en ${DB_HOST}:${DB_PORT}..."
until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" > /dev/null 2>&1; do
  sleep 1
done

# Si la base de datos no existe, inicializarla con módulo base
if ! venv/bin/python /opt/odoo/app/odoo-bin \
     -c /opt/odoo/app/rendered.conf --list-db | grep -qw "${DB_NAME:-fara}"; then
  echo "Base ${DB_NAME:-fara} no existe. Iniciando con -i base..."
  venv/bin/python /opt/odoo/app/odoo-bin \
    -c /opt/odoo/app/rendered.conf -d "${DB_NAME:-fara}" -i base
fi

# Iniciar Odoo normalmente (sin reinstalar base)
exec venv/bin/python /opt/odoo/app/odoo-bin -c /opt/odoo/app/rendered.conf "$@"
