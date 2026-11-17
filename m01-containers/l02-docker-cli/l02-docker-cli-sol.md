# Lab 1.2 – Lösung: Container bedienen

## Aufgabe 1: Zwei Container starten

```bash
docker run -d --name web1 -p 8081:80 nginx:1.30-alpine
docker run -d --name web2 -p 8082:80 nginx:1.30-alpine
docker ps
```

```text
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS         PORTS                  NAMES
8f2d41c09ab3   nginx:1.30-alpine   "/docker-entrypoint.…"   5 seconds ago   Up 4 seconds   0.0.0.0:8082->80/tcp   web2
51a7be3c2d10   nginx:1.30-alpine   "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   0.0.0.0:8081->80/tcp   web1
```

Beide Seiten zeigen „Welcome to nginx!". Beide Container lauschen intern auf Port 80; nur die Ports auf dem Rechner unterscheiden sich.

## Aufgabe 2: Logs lesen

```bash
docker logs web1
```

```text
/docker-entrypoint.sh: Configuration complete; ready for start up
…
192.168.65.1 - - [17/Nov/2026:09:41:12 +0000] "GET / HTTP/1.1" 200 615 "-" "Mozilla/5.0 …" "-"
192.168.65.1 - - [17/Nov/2026:09:41:14 +0000] "GET / HTTP/1.1" 200 615 "-" "Mozilla/5.0 …" "-"
```

```bash
docker logs -f --tail 5 web1
```

Nach dem Neuladen erscheint sofort eine weitere `GET /`-Zeile; `Strg+C` beendet nur das Mitlesen, nicht den Container. Die Absender-IP ist die Adresse der Docker-Desktop-VM; sie kann abweichen. Ein `GET /favicon.ico … 404` ist normal.

## Aufgabe 3: Datei im Container ändern

```bash
docker exec web1 sh -c 'echo "<h1>Neu aus web1</h1>" > /usr/share/nginx/html/index.html'
```

Kein Output bedeutet Erfolg. `http://localhost:8081` zeigt „Neu aus web1", `http://localhost:8082` weiter „Welcome to nginx!": Jeder Container hat seine eigene beschreibbare Schicht.

```bash
docker stop web1
docker start web1
```

```text
web1
web1
```

Die Änderung ist nach dem Neustart noch da, weil `stop` den Container nicht löscht.

## Aufgabe 4: Container löschen und neu starten

```bash
docker rm -f web1
docker run -d --name web1 -p 8081:80 nginx:1.30-alpine
```

`http://localhost:8081` zeigt wieder „Welcome to nginx!". Der neue Container startet aus dem unveränderten Image; die alte beschreibbare Schicht wurde mit `rm` gelöscht.

## Aufgabe 5: Mit Volume wiederholen

```bash
docker rm -f web1
docker run -d --name web1 -p 8081:80 -v web-data:/usr/share/nginx/html nginx:1.30-alpine
docker exec web1 sh -c 'echo "<h1>Neu aus web1</h1>" > /usr/share/nginx/html/index.html'
docker rm -f web1
docker run -d --name web1 -p 8081:80 -v web-data:/usr/share/nginx/html nginx:1.30-alpine
```

`http://localhost:8081` zeigt „Neu aus web1", obwohl der Container neu ist: Die Datei liegt im Volume `web-data`, nicht im Container. Beim ersten Einbinden hat Docker die Dateien des Images in das leere Volume kopiert.

```bash
docker volume ls
```

```text
DRIVER    VOLUME NAME
local     web-data
```

Aufräumen:

```bash
docker rm -f web1 web2
docker volume rm web-data
```

```text
web1
web2
web-data
```

## Erweiterung: Shell im Container

```bash
docker run -d --name web2 -p 8082:80 nginx:1.30-alpine
docker exec -it web2 sh
```

```text
/ # ls /usr/share/nginx/html
50x.html    index.html
/ # cat /etc/os-release
NAME="Alpine Linux"
…
/ # exit
```

Das Image basiert auf Alpine Linux, obwohl der Rechner macOS oder Windows nutzt. In Docker Desktop zeigen **Logs** dieselben Zeilen wie `docker logs`, **Exec** öffnet dieselbe Shell, **Files** das Dateisystem des Containers.

```bash
docker rm -f web2
```
