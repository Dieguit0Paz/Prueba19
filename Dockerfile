# Imagen base
FROM python:3.10-slim

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema y librerías necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gcc \
    g++ \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    libpq-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    python3-dev \
    libffi-dev \
    libbz2-dev \
    postgresql-client \
    wget \
    curl \
    unzip \
    gettext-base \
    npm \
    xfonts-75dpi \
    fontconfig \
    libxrender1 \
    libxext6 \
    && WK_ARCH=$(dpkg --print-architecture) \
    && curl -o /tmp/wkhtmltox.deb -sSL "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_${WK_ARCH}.deb" \
    && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
    && rm /tmp/wkhtmltox.deb \
    && npm install -g less less-plugin-clean-css \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario odoo y carpetas necesarias
RUN mkdir -p /opt/odoo/custom_addons /var/lib/odoo && \
    useradd -m -d /opt/odoo -U -r -s /bin/bash odoo && \
    chown -R odoo:odoo /opt/odoo /var/lib/odoo

# Definir directorio de trabajo
WORKDIR /opt/odoo/app

# Copiar el contenido del repositorio
COPY --chown=odoo:odoo . /opt/odoo/app

# Dar permisos de ejecución al script de entrada
RUN chmod +x /opt/odoo/app/entrypoint.sh

# Crear entorno virtual e instalar dependencias
RUN python -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt pdfminer.six google-auth

# Exponer puerto de Odoo
EXPOSE 8069

# Volúmenes persistentes
VOLUME ["/var/lib/odoo", "/opt/odoo/app/custom_addons"]

# Ejecutar script de arranque
ENTRYPOINT ["/opt/odoo/app/entrypoint.sh"]

