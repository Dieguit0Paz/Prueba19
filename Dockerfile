# Imagen base
FROM python:3.12-slim-bookworm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y wget gnupg2 build-essential zlib1g-dev libssl-dev libbz2-dev libffi-dev libreadline-dev && \
    wget -qO- https://pascalroeleven.nl/deb-pascalroeleven.gpg \
    | tee /etc/apt/keyrings/pascal-backport.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/pascal-backport.gpg] http://deb.pascalroeleven.nl/python3.12 bookworm-backports main" \
    > /etc/apt/sources.list.d/python3.12-backport.list && \
    apt-get update && apt-get install -y python3.12 python3.12-venv python3.12-dev wget gitnpm node-less wkhtmltopdf libxml2-dev libxslt-dev libjpeg-dev libpq-dev libldap2-dev libsasl2-dev libssl-dev && \
    apt-get clean

RUN npm install -g less less-plugin-clean-css

# Crear usuario odoo y carpetas necesarias
RUN mkdir -p /opt/odoo/custom_addons /var/lib/odoo && \
    useradd -m -d /opt/odoo -U -r -s /bin/bash odoo && \
    chown -R odoo:odoo /opt/odoo /var/lib/odoo


# Definir directorio de trabajo
WORKDIR /opt/odoo

# Clonar repositorio del proyecto (esto crea /opt/odoo/app)
RUN git clone https://github.com/Dieguit0Paz/Prueba19.git app

# Copiar script de arranque (después de clonar el repo)
COPY --chown=odoo:odoo entrypoint.sh /opt/odoo/app/entrypoint.sh
RUN chmod +x /opt/odoo/app/entrypoint.sh

# Crear entorno virtual e instalar dependencias
WORKDIR /opt/odoo/app
RUN python3.12 -m venv venv && \
    /opt/odoo/app/venv/bin/pip install --upgrade pip && \    
    /opt/odoo/app/venv/bin/pip install -r requirements.txt

# Exponer puerto de Odoo
EXPOSE 8069

# Volúmenes persistentes
VOLUME ["/var/lib/odoo", "/opt/odoo/app/custom_addons"]

# Ejecutar script de arranque
ENTRYPOINT ["/opt/odoo/app/entrypoint.sh"]
