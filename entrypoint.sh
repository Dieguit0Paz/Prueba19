#!/bin/bash
set -ex
source /opt/odoo/app/venv/bin/activate

export DB_PORT="${DB_PORT:-5432}"
envsubst < /opt/odoo/app/odoo.conf > /opt/odoo/app/rendered.conf

echo "Esperando host ${DB_HOST}:${DB_PORT}..."
until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" > /dev/null 2>&1; do
  sleep 1
done

echo "Listado de bases (psql):"
PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -l

if ! PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -lqt \
     | cut -d '|' -f1 | grep -qw "${DB_NAME:-fara}"; then
  echo "La base ${DB_NAME:-fara} no existe. Creando con -i base..."
  venv/bin/python /opt/odoo/app/odoo-bin \
    -c /opt/odoo/app/rendered.conf -d "${DB_NAME:-fara}" -i base
fi

echo "Iniciando Odoo..."
exec venv/bin/python /opt/odoo/app/odoo-bin -c /opt/odoo/app/rendered.conf "$@"
