# Lab 1.3 – Übung: Images bauen

**Dauer:** ca. 25 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — es entstehen `playground/backend/Dockerfile`, `playground/frontend/Dockerfile` und die Images `hello-backend:v1`, `hello-frontend:v1`, `hello-frontend:v2`, die ab Lab 3.1 in Kubernetes laufen.

## Vorbereitung

- Terminal im Ordner `project/` öffnen (Pfad siehe [Setup](../../00-setup-and-installation.md#kursdateien-holen)); den Kursordner in VS Code öffnen.
- Starter: [`project/starters/m01-l03-backend.Dockerfile`](../../project/starters/m01-l03-backend.Dockerfile) und [`project/starters/m01-l03-frontend.Dockerfile`](../../project/starters/m01-l03-frontend.Dockerfile)
- Arbeitsdateien: `project/playground/backend/Dockerfile` und `project/playground/frontend/Dockerfile`
- Port 8080 und 8081 frei: `docker ps` zeigt keine Container aus Lab 1.1/1.2.

## Aufgaben

1. Kopiere den Backend-Starter mit `cp starters/m01-l03-backend.Dockerfile playground/backend/Dockerfile`, ersetze in VS Code alle `# TODO:`-Zeilen durch die passenden Anweisungen und baue im Ordner `playground/backend` das Image `hello-backend:v1`.
2. Kopiere den Frontend-Starter nach `playground/frontend/Dockerfile`, ergänze die beiden TODOs (`ENV` mit `APP_VERSION=v1`, `APP_COLOR=lightblue`, `PORT=80` und `CMD`) und baue `hello-frontend:v1`.
3. Starte aus dem Ordner `project/` beide Images: das Backend als Container `backend` auf Port 8081, das Frontend als Container `frontend` auf Port 8080 mit `-e BACKEND_URL=http://host.docker.internal:8081`. Öffne `http://localhost:8080` und `http://localhost:8081`.
4. Ändere in `playground/frontend/Dockerfile` die `ENV`-Zeile auf `APP_VERSION=v2` und `APP_COLOR=lightgreen`, baue `hello-frontend:v2` und achte in der Build-Ausgabe auf `CACHED`. Ersetze danach den Container `frontend` durch einen mit `hello-frontend:v2` (gleiche Optionen wie in Aufgabe 3) und lade die Seite neu.
5. Zeige mit `docker images --filter "reference=hello-*"` die drei Images an und entferne danach beide Container mit `docker rm -f backend frontend`.

## Checkpoint

- Beide Builds enden ohne Fehler mit `naming to docker.io/library/hello-…`.
- `http://localhost:8081` liefert JSON mit `"version": "v1"`.
- `http://localhost:8080` ist hellblau, zeigt „Hello-App v1" und unter **Backend** eine Antwort mit Uhrzeit (kein „Backend nicht erreichbar").
- Der Build von `v2` zeigt bei `WORKDIR`, `COPY` und `RUN` jeweils `CACHED`; danach ist die Seite hellgrün mit „Hello-App v2".

## Abschlusskriterien

- `docker images --filter "reference=hello-*"` listet `hello-backend:v1`, `hello-frontend:v1` und `hello-frontend:v2`.
- `playground/backend/Dockerfile` und `playground/frontend/Dockerfile` enthalten keine `TODO` mehr.
- Die Container `backend` und `frontend` sind entfernt; Port 8080 ist für Lab 3.1 frei.

## Erweiterung

Starte `hello-frontend:v1` ein weiteres Mal als Container `frontend-pink` auf Port 8090 mit `-e APP_COLOR=pink` (ohne neues Image) und vergleiche die Seite mit Port 8080. Entferne den Container danach mit `docker rm -f frontend-pink`.

## Fallback

- Fertige Dockerfiles zum Vergleichen oder Kopieren: [`project/examples/m01-containers/l03-images/`](../../project/examples/m01-containers/l03-images/) (`backend/Dockerfile`, `frontend/Dockerfile` für v1, `frontend/Dockerfile.v2`).
- Alle Hello-Images auf einmal neu bauen (z. B. auf einem neuen Rechner): im Ordner `project/` `bash build-images.sh` ausführen.
- `toomanyrequests` beim Laden von `python:3.14-alpine`: `docker login` ([Setup](../../00-setup-and-installation.md#docker-hub-limit-und-docker-login)).
