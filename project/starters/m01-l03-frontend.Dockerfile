# Lab 1.3 – Starter: Dockerfile für das Hello-Frontend
# Kopieren nach playground/frontend/Dockerfile, dann die "# TODO:"-Zeilen ersetzen.

FROM python:3.14-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# TODO: Umgebungsvariablen setzen (ENV): APP_VERSION=v1, APP_COLOR=lightblue, PORT=80

EXPOSE 80

# TODO: Startbefehl "python app.py" in JSON-Schreibweise festlegen (CMD)
