# Lab 1.3 – Starter: Dockerfile für das Hello-Backend
# Kopieren nach playground/backend/Dockerfile, dann jede "# TODO:"-Zeile
# durch die passende Anweisung ersetzen (Tabelle im Theorieteil von Lab 1.3).

# TODO: Basisimage python:3.14-alpine festlegen (FROM)

# Arbeitsordner im Image; alle folgenden Pfade beziehen sich darauf
WORKDIR /app

# Erst nur die Abhängigkeiten: diese Schicht bleibt im Cache,
# solange sich requirements.txt nicht ändert
# TODO: requirements.txt in den Arbeitsordner kopieren (COPY)
RUN pip install --no-cache-dir -r requirements.txt

# TODO: app.py in den Arbeitsordner kopieren (COPY)

# Standardwerte, beim Start überschreibbar (docker run -e)
ENV APP_VERSION=v1 \
    PORT=80

# TODO: Port 80 dokumentieren (EXPOSE)

# TODO: Startbefehl "python app.py" in JSON-Schreibweise festlegen (CMD)
