# Basisimage: Python 3.14 auf Alpine Linux (klein, aktuell unterstützt)
FROM python:3.14-alpine

# Arbeitsordner im Image; alle folgenden Pfade beziehen sich darauf
WORKDIR /app

# Erst nur die Abhängigkeiten kopieren und installieren: diese Schicht bleibt im Cache,
# solange sich requirements.txt nicht ändert
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Danach den Code kopieren (ändert sich oft)
COPY app.py .

# Eigener Benutzer ohne root-Rechte (UID 10001) und ein Datenordner, der ihm gehört
RUN adduser -D -u 10001 hello && mkdir -p /data && chown 10001 /data
USER 10001

# Standardwerte, beim Start überschreibbar (docker run -e / Kubernetes env)
ENV APP_VERSION=v1 \
    PORT=8080

# Ports unter 1024 brauchen root-Rechte, deshalb 8080
EXPOSE 8080

# Startbefehl des Containers
CMD ["python", "app.py"]
