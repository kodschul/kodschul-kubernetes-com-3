# Lab 1.3 – Lösung: Images bauen

## Aufgabe 1: Backend-Dockerfile und hello-backend:v1

```bash
cp starters/m01-l03-backend.Dockerfile playground/backend/Dockerfile
```

`playground/backend/Dockerfile` nach dem Ersetzen der TODOs (Kommentare gekürzt):

```dockerfile
FROM python:3.14-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV APP_VERSION=v1 \
    PORT=80

EXPOSE 80

CMD ["python", "app.py"]
```

```bash
cd playground/backend
docker build -t hello-backend:v1 .
cd ../..
```

```text
[+] Building 18.4s (10/10) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load metadata for docker.io/library/python:3.14-alpine
 => [internal] load .dockerignore
 => [1/5] FROM docker.io/library/python:3.14-alpine@sha256:…
 => [internal] load build context
 => [2/5] WORKDIR /app
 => [3/5] COPY requirements.txt .
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt
 => [5/5] COPY app.py .
 => exporting to image
 => => naming to docker.io/library/hello-backend:v1
```

Fünf Schritte, je einer pro `FROM`, `WORKDIR`, `COPY`, `RUN`, `COPY`; `ENV`, `EXPOSE` und `CMD` ändern nur die Beschreibung des Images. Vergleich: [`examples/m01-containers/l03-images/backend/Dockerfile`](../../project/examples/m01-containers/l03-images/backend/Dockerfile).

## Aufgabe 2: Frontend-Dockerfile und hello-frontend:v1

```bash
cp starters/m01-l03-frontend.Dockerfile playground/frontend/Dockerfile
```

Die beiden ergänzten Stellen:

```dockerfile
ENV APP_VERSION=v1 \
    APP_COLOR=lightblue \
    PORT=80

CMD ["python", "app.py"]
```

```bash
cd playground/frontend
docker build -t hello-frontend:v1 .
cd ../..
```

Der Schritt `[1/5] FROM` kommt jetzt aus dem Cache, weil das Basisimage schon von Aufgabe 1 vorliegt. Vergleich: [`examples/m01-containers/l03-images/frontend/Dockerfile`](../../project/examples/m01-containers/l03-images/frontend/Dockerfile).

## Aufgabe 3: Beide Container starten

```bash
docker run -d --name backend -p 8081:80 hello-backend:v1
docker run -d --name frontend -p 8080:80 \
  -e BACKEND_URL=http://host.docker.internal:8081 hello-frontend:v1
```

`http://localhost:8081`:

```json
{
  "ip": "172.17.0.2",
  "pod": "5d0c3b8e9f12",
  "time": "10:12:41",
  "version": "v1"
}
```

`http://localhost:8080` zeigt eine hellblaue Seite:

```text
Hello-App v1
Frontend-Pod: 8a41f0e2c7d3 (172.17.0.3)
Backend: 5d0c3b8e9f12 (172.17.0.2) um 10:12:44
Admin: kein Passwort gesetzt
```

Unter Docker heißt der „Pod" noch Container-ID: Die App zeigt den Hostnamen, und den setzt Docker auf die kurze Container-ID. In Kubernetes steht dort ab Lab 3.1 der Pod-Name. „kein Passwort gesetzt" ist richtig; das Passwort kommt erst in Lab 6.2 dazu. IDs und IPs weichen ab.

```bash
docker logs frontend
```

```text
Hello-Frontend v1 auf Port 80, Backend: http://host.docker.internal:8081
 * Serving Flask app 'app'
 …
192.168.65.1 - - [17/Nov/2026 10:12:44] "GET / HTTP/1.1" 200 -
```

Die Warnung `This is a development server` von Flask ist für den Kurs in Ordnung.

## Aufgabe 4: Version v2 bauen und starten

In `playground/frontend/Dockerfile`:

```dockerfile
ENV APP_VERSION=v2 \
    APP_COLOR=lightgreen \
    PORT=80
```

```bash
cd playground/frontend
docker build -t hello-frontend:v2 .
cd ../..
```

```text
[+] Building 0.9s (10/10) FINISHED
 => [1/5] FROM docker.io/library/python:3.14-alpine@sha256:…
 => CACHED [2/5] WORKDIR /app
 => CACHED [3/5] COPY requirements.txt .
 => CACHED [4/5] RUN pip install --no-cache-dir -r requirements.txt
 => CACHED [5/5] COPY app.py .
 => exporting to image
 => => naming to docker.io/library/hello-frontend:v2
```

Alle Dateischichten kommen aus dem Cache; neu ist nur die Beschreibung mit den geänderten Umgebungsvariablen. Deshalb dauert der Build unter einer Sekunde.

```bash
docker rm -f frontend
docker run -d --name frontend -p 8080:80 \
  -e BACKEND_URL=http://host.docker.internal:8081 hello-frontend:v2
```

Die Seite ist jetzt hellgrün und zeigt „Hello-App v2". `playground/frontend/Dockerfile` beschreibt ab jetzt v2; das Image `hello-frontend:v1` bleibt trotzdem erhalten. Vergleich: [`examples/m01-containers/l03-images/frontend/Dockerfile.v2`](../../project/examples/m01-containers/l03-images/frontend/Dockerfile.v2).

## Aufgabe 5: Images anzeigen und aufräumen

```bash
docker images --filter "reference=hello-*"
```

```text
REPOSITORY       TAG   IMAGE ID       CREATED          SIZE
hello-frontend   v2    4e7a9c1b2d30   1 minute ago     78.6MB
hello-frontend   v1    c2b8f0a91e47   4 minutes ago    78.6MB
hello-backend    v1    9a0d5e3f7b21   6 minutes ago    71.2MB
```

Größen sind Richtwerte; mit dem containerd-Image-Store zeigt Docker Desktop andere Werte und eine Ansicht mit den Spalten `IMAGE`, `ID`, `DISK USAGE`.

```bash
docker rm -f backend frontend
```

```text
backend
frontend
```

## Erweiterung: Farbe ohne neues Image

```bash
docker run -d --name frontend-pink -p 8090:80 -e APP_COLOR=pink \
  -e BACKEND_URL=http://host.docker.internal:8081 hello-frontend:v1
docker rm -f frontend-pink
```

`-e` überschreibt den Standardwert aus `ENV`: dasselbe Image `v1`, aber pinke Seite. Läuft das Backend nicht mehr (nach Aufgabe 5), zeigt die Seite „Backend nicht erreichbar" – das Frontend stürzt dabei nicht ab. Dieses Prinzip, Einstellungen von außen zu setzen, nutzt Kubernetes ab Lab 3.1 mit `env` und ab Lab 6.1 mit ConfigMaps.
