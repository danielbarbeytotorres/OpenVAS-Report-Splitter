# Stage 1: Builder
FROM python:3.11-slim as builder

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Runtime
FROM python:3.11-slim

# Metadatos
LABEL maintainer="Daniel Barbeyto Torres <danielbarbeytotorres@example.com>" \
      description="OpenVAS Report Splitter - Herramienta de automatización para post-procesado de informes OpenVAS" \
      version="1.0"

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app:$PATH"

# Crear usuario no-root para seguridad
RUN useradd -m -u 1000 -s /bin/bash appuser

# Instalar dependencias del sistema (gum para UI, curl para utilidades)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gum \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir gvm-tools

# Establecer directorio de trabajo
WORKDIR /app

# Copiar el repositorio
COPY . .

# Ajustar permisos
RUN chmod +x pipeline.sh && \
    chown -R appuser:appuser /app

# Cambiar a usuario no-root
USER appuser

# Crear directorios de salida con permisos correctos
RUN mkdir -p /app/reports

# Healthcheck (verifica que el script sea ejecutable)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=1 \
    CMD [ -x "/app/pipeline.sh" ] && echo "OK" || exit 1

# Punto de entrada
CMD ["/app/pipeline.sh"]