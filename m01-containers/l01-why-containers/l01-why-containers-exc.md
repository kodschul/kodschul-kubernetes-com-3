# Lab 1.1 – Übung: Warum Container?

**Dauer:** ca. 10 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — die Übung nutzt nur öffentliche Images; die Hello-App folgt in Lab 1.3.

## Vorbereitung

- Docker Desktop läuft (Statusleiste `Engine running`), siehe [Setup und Installation](../../00-setup-and-installation.md).
- Terminal öffnen: macOS/Linux Terminal, Windows Git Bash. Ein bestimmter Ordner ist nicht nötig.
- Starter und Arbeitsdatei: keine, alle Schritte sind Befehle.

## Aufgaben

1. Prüfe mit `docker version`, dass Client und Server (Docker Engine) antworten.
2. Starte den Testcontainer mit `docker run hello-world` und lies in der Ausgabe die vier Schritte, die Docker dabei ausgeführt hat.
3. Starte den Webserver nginx im Hintergrund mit Namen `web` und Port-Freigabe: `docker run -d --name web -p 8080:80 nginx:1.30-alpine`.
4. Öffne `http://localhost:8080` im Browser und zeige danach mit `docker ps` den laufenden Container und mit `docker images` die geladenen Images an.
5. Entferne den Container mit `docker rm -f web` und lade die Seite im Browser neu.

## Checkpoint

- `docker version` zeigt einen Abschnitt `Client` und einen Abschnitt `Server`.
- `hello-world` gibt `Hello from Docker!` aus.
- Der Browser zeigt „Welcome to nginx!".
- `docker ps` listet `web` mit `0.0.0.0:8080->80/tcp`; `docker images` listet `hello-world` und `nginx` mit Tag `1.30-alpine`.
- Nach Aufgabe 5 ist die Seite nicht mehr erreichbar.

## Abschlusskriterien

- Ein Container aus einem Docker-Hub-Image lief und war im Browser erreichbar.
- Am Ende läuft kein Container `web` mehr (`docker ps` ist leer oder zeigt ihn nicht).

## Erweiterung

Starte denselben Webserver ein zweites Mal mit anderem Namen und Port (`--name web2 -p 8090:80`) und öffne `http://localhost:8090`. Entferne ihn danach mit `docker rm -f web2`.

## Fallback

- `toomanyrequests` beim Download: mit `docker login` anmelden ([Setup](../../00-setup-and-installation.md#docker-hub-limit-und-docker-login)) und den Befehl wiederholen.
- Port 8080 belegt: in Aufgabe 3 `-p 8090:80` nutzen und `http://localhost:8090` öffnen.
