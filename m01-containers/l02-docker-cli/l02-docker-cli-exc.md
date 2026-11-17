# Lab 1.2 – Übung: Container bedienen

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — die Übung nutzt nginx-Container; am Ende werden alle Container und das Volume wieder entfernt.

## Vorbereitung

- Docker Desktop läuft; Terminal (macOS/Linux: Terminal, Windows: Git Bash mit `MSYS_NO_PATHCONV=1`, siehe [Setup](../../00-setup-and-installation.md#kurs-shell-bash)).
- Starter und Arbeitsdatei: keine, alle Schritte sind Befehle.
- Kein Container `web1` oder `web2` vorhanden: `docker ps -a` prüfen, Reste mit `docker rm -f web1 web2` entfernen.

## Aufgaben

1. Starte zwei nginx-Container `web1` (Port 8081) und `web2` (Port 8082) aus dem Image `nginx:1.30-alpine`, öffne beide Seiten im Browser und zeige beide Container mit `docker ps` an.
2. Lade `http://localhost:8081` zweimal neu und lies die Anfragen mit `docker logs web1`. Lies danach mit `docker logs -f --tail 5 web1` live mit, lade die Seite erneut und beende das Mitlesen mit `Strg+C`.
3. Ersetze in `web1` die Startseite per `exec`:
   `docker exec web1 sh -c 'echo "<h1>Neu aus web1</h1>" > /usr/share/nginx/html/index.html'`
   Lade beide Seiten neu. Stoppe `web1` danach mit `docker stop`, starte ihn mit `docker start` und lade die Seite erneut.
4. Entferne `web1` mit `docker rm -f web1`, starte ihn mit demselben `docker run`-Befehl aus Aufgabe 1 neu und lade `http://localhost:8081`.
5. Wiederhole Aufgabe 3 und 4 mit einem Volume: Entferne `web1`, starte ihn mit zusätzlich `-v web-data:/usr/share/nginx/html`, ändere die Startseite wie in Aufgabe 3, entferne den Container und starte ihn mit demselben Volume neu. Räume zum Schluss mit `docker rm -f web1 web2` und `docker volume rm web-data` auf.

## Checkpoint

- `docker ps` zeigt `web1` mit `0.0.0.0:8081->80/tcp` und `web2` mit `0.0.0.0:8082->80/tcp`.
- `docker logs web1` zeigt je Seitenaufruf eine Zeile mit `"GET / HTTP/1.1" 200`.
- Nach Aufgabe 3 zeigt nur Port 8081 „Neu aus web1"; nach `stop`/`start` ist die Änderung noch da.
- Nach Aufgabe 4 zeigt Port 8081 wieder „Welcome to nginx!".
- In Aufgabe 5 zeigt Port 8081 auch nach `rm` und neuem `run` „Neu aus web1".

## Abschlusskriterien

- Der Unterschied ist beobachtet: Änderung im Container weg nach `docker rm`, Änderung im Volume bleibt.
- Am Ende laufen weder `web1` noch `web2`, und `docker volume ls` listet `web-data` nicht mehr.

## Erweiterung

Starte `web2` wie in Aufgabe 1 neu und öffne mit `docker exec -it web2 sh` eine Shell darin (Git Bash: `winpty` voranstellen, falls nötig), zeige mit `ls /usr/share/nginx/html` und `cat /etc/os-release` den Inhalt an und verlasse die Shell mit `exit`. Öffne danach denselben Container in Docker Desktop und vergleiche die Reiter **Logs**, **Exec** und **Files**. Entferne `web2` danach mit `docker rm -f web2`.

## Fallback

- Port 8081 oder 8082 belegt: andere freie Ports wählen (z. B. 8091, 8092) und im Browser entsprechend aufrufen.
- `toomanyrequests` beim Download: `docker login` ([Setup](../../00-setup-and-installation.md#docker-hub-limit-und-docker-login)).
