#!/bin/bash
set -ex
source /opt/odoo/app/venv/bin/activate

export DB_PORT="${DB_PORT:-5432}"
envsubst < /opt/odoo/app/odoo.conf > /opt/odoo/app/rendered.conf

echo "Esperando host ${DB_HOST}:${DB_PORT}..."
until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" > /dev/null 2>&1; do
  sleep 1
done

echo "Chequeando existencia de la base con SQL directo..."
EXISTS=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" \
  -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME:-fara}'")
if [ "$EXISTS" != "1" ]; then
  echo "La base ${DB_NAME:-fara} no existe. Creando e instalando módulo base..."
  venv/bin/python /opt/odoo/app/odoo-bin \
    -c /opt/odoo/app/rendered.conf -d "${DB_NAME:-fara}" -i base
fi


echo "Iniciando Odoo..."
exec venv/bin/python /opt/odoo/app/odoo-bin -c /opt/odoo/app/rendered.conf "$@"
