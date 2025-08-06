#!/bin/bash

# Activar entorno virtual
source /opt/odoo/app/venv/bin/activate

# Generar archivo de configuración si no existe
if [ ! -f /opt/odoo/app/odoo.conf ]; then
  cat > /opt/odoo/app/odoo.conf <<EOF
[options]
addons_path = ${ADDONS_PATH}
admin_passwd = ${ADMIN_PASSWORD}
db_host = ${DB_HOST}
db_port = ${DB_PORT}
db_user = ${DB_USER}
db_password = ${DB_PASSWORD}
log_level = info
web.base.url = ${WEBBASEURL}
database.expiration_date = ${DATABASEEXPIRATION_DATE}
data_dir = ${ODOO_DATA_DIR}
proxy_mode = ${PROXY_MODE}
EOF
fi

# Ejecutar Odoo usando el archivo de configuración
exec python /opt/odoo/app/odoo-bin -c /opt/odoo/app/odoo.conf
