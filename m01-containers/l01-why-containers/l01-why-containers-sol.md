# Lab 1.1 – Lösung: Warum Container?

## Aufgabe 1: Docker prüfen

```bash
docker version
```

```text
Client:
 Version:           29.x.x
 API version:       1.5x
 OS/Arch:           darwin/arm64
 …
Server: Docker Desktop 4.99.0 (…)
 Engine:
  Version:          29.x.x
  OS/Arch:          linux/arm64
 …
```

Versionsnummern und `OS/Arch` hängen vom Rechner ab. Der Server meldet `linux/…`, auch unter macOS und Windows: Die Engine läuft in der Linux-VM von Docker Desktop. Fehlt der Abschnitt `Server`, läuft Docker Desktop nicht.

## Aufgabe 2: hello-world

```bash
docker run hello-world
```

```text
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
…
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
…
```

Die vier Schritte entsprechen dem Bild aus der Theorie: CLI → Engine → Registry (Pull) → Container. Der Container beendet sich nach der Ausgabe sofort, weil sein Programm fertig ist.

## Aufgabe 3: nginx im Hintergrund

```bash
docker run -d --name web -p 8080:80 nginx:1.30-alpine
```

```text
Unable to find image 'nginx:1.30-alpine' locally
1.30-alpine: Pulling from library/nginx
…
Status: Downloaded newer image for nginx:1.30-alpine
3c1f9e0d4a7b5e…
```

Die lange Zeichenkette am Ende ist die Container-ID. Mit `-d` kehrt das Terminal sofort zurück.

## Aufgabe 4: Browser, docker ps und docker images

Der Browser zeigt unter `http://localhost:8080` die Seite „Welcome to nginx!".

```bash
docker ps
```

```text
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                  NAMES
3c1f9e0d4a7b   nginx:1.30-alpine   "/docker-entrypoint.…"   30 seconds ago   Up 29 seconds   0.0.0.0:8080->80/tcp   web
```

```bash
docker images
```

```text
REPOSITORY    TAG           IMAGE ID       CREATED       SIZE
nginx         1.30-alpine   9b1e2c3d4f5a   2 weeks ago   52.5MB
hello-world   latest        1b44b5a3e06a   3 months ago  10.1kB
```

`hello-world` erscheint nicht in `docker ps`, weil der Container bereits beendet ist. IDs, Datumsangaben und Größen weichen ab; neuere Docker-Versionen zeigen die Image-Liste in einer Ansicht mit den Spalten `IMAGE`, `ID` und `DISK USAGE`.

## Aufgabe 5: Container entfernen

```bash
docker rm -f web
```

```text
web
```

`rm` entfernt den Container, `-f` stoppt ihn vorher. Der Browser meldet danach, dass die Seite nicht erreichbar ist. Das Image `nginx:1.30-alpine` bleibt lokal gespeichert; der nächste `docker run` startet ohne Download.

## Erweiterung: zweiter Webserver

```bash
docker run -d --name web2 -p 8090:80 nginx:1.30-alpine
docker ps
docker rm -f web2
```

Aus demselben Image laufen beliebig viele Container; jeder braucht einen eigenen Namen und einen freien Port auf dem Rechner. Der Start dauert keine Sekunde, weil das Image schon lokal liegt.
