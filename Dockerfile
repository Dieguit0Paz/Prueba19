# Imagen base
FROM python:3.10-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    wkhtmltopdf \
    gcc \
    g++ \
    libxml2-dev \
    libxslt-dev \
    libjpeg-dev \
    libpq-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    python3-dev \
    libffi-dev \
    libbz2-dev \
    wget \
    curl \
    unzip \
    node-less \
    cython3 \
    npm && \
    npm install -g less less-plugin-clean-css && \
    apt-get clean

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
RUN python -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt pdfminer google-auth

USER odoo
RUN venv/bin/python /opt/odoo/app/odoo-bin -c odoo.conf -d fara -i base

# Exponer puerto de Odoo
EXPOSE 8069

# Volúmenes persistentes
VOLUME ["/var/lib/odoo", "/opt/odoo/app/custom_addons"]

# Ejecutar script de arranque
ENTRYPOINT ["/opt/odoo/app/entrypoint.sh"]
