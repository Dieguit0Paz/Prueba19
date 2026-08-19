#!/bin/bash

# Activar entorno virtual
source /opt/odoo/app/venv/bin/activate

# Generar archivo de configuracion si no existe
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

# Reset admin password in database fara if DB exists
python /opt/odoo/app/odoo-bin shell -c /opt/odoo/app/odoo.conf -d fara --no-http << "EOF"
try:
    users = env["res.users"].search([("active", "=", True)])
    print("ALL ACTIVE USERS IN DB:", [(u.id, u.login, u.name) for u in users])
    admin_user = env["res.users"].search([("login", "in", ["admin", "elcapopaz@hotmail.com", "eliasfara727@hotmail.com"])], limit=1)
    if not admin_user:
        admin_user = env["res.users"].browse(2)
    if admin_user.exists():
        admin_user.write({"password": "dionicio"})
        env.cr.commit()
        print(f"SUCCESS: Reset password for user {admin_user.login} (ID {admin_user.id}) to dionicio")
except Exception as e:
    print("Shell password reset error:", e)
EOF

# Ejecutar Odoo usando el archivo de configuracion
exec python /opt/odoo/app/odoo-bin -c /opt/odoo/app/odoo.conf

