# Docker – Cheatsheet (Modul 1)

## Container starten und anzeigen

| Befehl | Wirkung |
| --- | --- |
| `docker version` | Client- und Server-Version anzeigen; prüft, ob Docker läuft |
| `docker run hello-world` | Testcontainer starten; lädt das Image bei Bedarf |
| `docker run -d --name web -p 8080:80 nginx:1.30-alpine` | Container im Hintergrund (`-d`), mit Namen und Port-Freigabe Rechner 8080 → Container 80 |
| `docker run -d -e APP_COLOR=pink …` | Umgebungsvariable setzen bzw. `ENV`-Standardwert überschreiben |
| `docker run --rm hello-world` | Container nach dem Ende automatisch entfernen |
| `docker run --rm busybox:1.37 echo "Hallo"` | einzelnen Befehl in einem neuen Container ausführen; Container endet danach |
| `docker run -it --rm busybox:1.37 sh` | interaktive Shell in einem neuen Container (`exit` beendet ihn) |
| `docker ps` | laufende Container |
| `docker ps -a` | alle Container, auch gestoppte |

## Lebenszyklus

| Befehl | Wirkung |
| --- | --- |
| `docker stop web` | Container sauber beenden (`SIGTERM`, nach 10 s `SIGKILL`); Änderungen bleiben erhalten |
| `docker kill web` | Container sofort hart beenden (`SIGKILL`), nur wenn `stop` nicht reagiert |
| `docker start web` | gestoppten Container wieder starten |
| `docker restart web` | stoppen und starten |
| `docker rm web` | gestoppten Container entfernen |
| `docker rm -f web1 web2` | Container stoppen und entfernen (auch mehrere) |

## Beobachten und hineinschauen

| Befehl | Wirkung |
| --- | --- |
| `docker logs web` | bisherige Ausgaben des Containers |
| `docker logs -f --tail 5 web` | letzte 5 Zeilen, danach live mitlesen (`Strg+C` beendet) |
| `docker exec web ls /usr/share/nginx/html` | einen Befehl im laufenden Container ausführen |
| `docker exec -it web sh` | interaktive Shell im Container (`exit` beendet); Git Bash: `winpty` voranstellen, falls nötig |
| `docker inspect web` | alle Details des Containers als JSON |
| `docker inspect -f '{{.State.Status}}' web` | ein einzelnes Feld ausgeben |
| `docker stats` / `docker stats --no-stream` | CPU und Speicher je Container live / einmalig |
| `docker cp web:/etc/nginx/conf.d/default.conf .` | Datei aus dem Container auf den Rechner kopieren |
| `docker cp default.conf web:/etc/nginx/conf.d/default.conf` | Datei vom Rechner in den Container kopieren |

## Volumes

| Befehl | Wirkung |
| --- | --- |
| `docker volume create web-data` | Volume anlegen |
| `docker run -v web-data:/usr/share/nginx/html …` | Volume an einem Pfad im Container einbinden |
| `docker run -v /pfad/auf/dem/rechner:/pfad/im/container …` | Bind-Mount: Ordner des Rechners einbinden |
| `docker volume ls` | Volumes anzeigen |
| `docker volume rm web-data` | Volume löschen (kein Container darf es nutzen) |

## Images bauen und verwalten

| Befehl | Wirkung |
| --- | --- |
| `docker build -t hello-backend:v1 .` | Image aus dem `Dockerfile` im aktuellen Ordner bauen, Name `hello-backend`, Tag `v1` |
| `docker build --build-arg PYTHON_VERSION=3.13 -t …` | Wert für ein `ARG` im Dockerfile übergeben |
| `docker images` | lokale Images |
| `docker history hello-backend:v1` | Schichten eines Images mit Anweisung und Größe |
| `docker images --filter "reference=hello-*"` | nur Images, deren Name mit `hello-` beginnt |
| `docker pull nginx:1.30-alpine` | Image aus der Registry laden, ohne Container zu starten |
| `docker login` | bei Docker Hub anmelden (höheres Pull-Limit) |
| `bash build-images.sh` | (im Ordner `project/`) alle Hello-Images aus den Beispielen neu bauen |

## Dockerfile-Anweisungen

| Anweisung | Wirkung |
| --- | --- |
| `FROM python:3.14-alpine` | Basisimage |
| `WORKDIR /app` | Arbeitsordner im Image |
| `COPY requirements.txt .` | Datei aus dem Build-Kontext kopieren |
| `RUN pip install --no-cache-dir -r requirements.txt` | Befehl beim Bauen ausführen |
| `ENV APP_VERSION=v1` | Umgebungsvariable mit Standardwert |
| `EXPOSE 80` | Port dokumentieren |
| `USER 10001` | Benutzer für den Start festlegen |
| `CMD ["python", "app.py"]` | Startbefehl des Containers bzw. Standard-Argumente zu `ENTRYPOINT` |
| `ENTRYPOINT ["python", "app.py"]` | festes Startprogramm |
| `ARG PYTHON_VERSION=3.14` | Variable nur beim Bauen |
| `ADD app.tar.gz /app/` | wie `COPY`, entpackt Archive und lädt URLs |
| `VOLUME /data` | Ordner für Daten markieren |
| `LABEL org.opencontainers.image.source="…"` | Metadaten |
| `HEALTHCHECK CMD wget -qO- http://localhost/healthz \|\| exit 1` | Gesundheitsprüfung durch Docker (Kubernetes nutzt Probes) |
| `FROM … AS build` / `COPY --from=build …` | mehrstufiger Build: Datei aus einer früheren Stufe übernehmen |

## Hello-App lokal mit Docker

| Befehl | Wirkung |
| --- | --- |
| `docker run -d --name backend -p 8081:80 hello-backend:v1` | Backend auf `http://localhost:8081` |
| `docker run -d --name frontend -p 8080:80 -e BACKEND_URL=http://host.docker.internal:8081 hello-frontend:v1` | Frontend auf `http://localhost:8080`, ruft das Backend über den Rechner auf |
| `docker rm -f backend frontend` | beide Container entfernen |
