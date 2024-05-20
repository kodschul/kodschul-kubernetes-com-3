## Docker: Einführung in Docker-Netzwerke

Docker ermöglicht die Erstellung, Bereitstellung und Ausführung von Anwendungen in Containern. Docker-Netzwerke spielen dabei eine wichtige Rolle, indem sie die Kommunikation zwischen Containern ermöglichen. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in Docker-Netzwerke:

### Beispiel 1: Verwendung des Standardnetzwerks

```bash
# Erstellen und Ausführen eines Containers ohne explizite Netzwerkspezifikation
docker run -d --name container1 nginx

# Erstellen und Ausführen eines weiteren Containers im selben Standardnetzwerk
docker run -d --name container2 nginx

# Überprüfen der Netzwerkkonfiguration der Container
docker network inspect bridge
```

In diesem Beispiel werden zwei Container (basierend auf dem Image nginx) im Standardnetzwerk erstellt und ausgeführt. Das Standardnetzwerk wird automatisch erstellt, wenn kein spezifisches Netzwerk angegeben ist.

### Beispiel 2: Erstellung eines benutzerdefinierten Netzwerks

```bash
# Erstellen eines benutzerdefinierten Netzwerks
docker network create mynetwork

# Erstellen und Ausführen eines Containers im benutzerdefinierten Netzwerk
docker run -d --name container3 --network mynetwork nginx

# Überprüfen der Netzwerkkonfiguration des benutzerdefinierten Netzwerks
docker network inspect mynetwork
```

Hier wird ein benutzerdefiniertes Docker-Netzwerk namens mynetwork erstellt und ein Container (basierend auf dem Image nginx) in diesem Netzwerk erstellt und ausgeführt.

### Beispiel 3: Verwendung von Links zwischen Containern

```bash
# Erstellen und Ausführen eines MySQL-Containers
docker run -d --name mysql-db -e MYSQL_ROOT_PASSWORD=my-secret-pw mysql

# Erstellen und Ausführen eines Containers mit einer Anwendung, die auf die MySQL-Datenbank zugreift
docker run -d --name webapp --link mysql-db:mysql my-webapp
```

Hier wird ein Container mit einer MySQL-Datenbank erstellt und ausgeführt. Anschließend wird ein weiterer Container mit einer Anwendung erstellt und ausgeführt, der über den Link mysql-db auf die MySQL-Datenbank zugreift.

## Docker: Erstellen und Verwalten von Docker-Netzwerken

Docker ermöglicht das Erstellen und Verwalten von Docker-Netzwerken, die es Containern ermöglichen, miteinander zu kommunizieren. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Erstellung und Verwaltung von Docker-Netzwerken:

### Beispiel 1: Erstellen eines Docker-Netzwerks

```bash
docker network create my_network
```

Dieser Befehl erstellt ein neues Docker-Netzwerk mit dem Namen "my_network". Standardmäßig handelt es sich um ein Bridge-Netzwerk.

### Beispiel 2: Anzeigen von Docker-Netzwerken

```bash
docker network ls
```

Dieser Befehl listet alle vorhandenen Docker-Netzwerke auf dem Hostsystem auf, einschließlich ihrer Namen, IDs und Treiber.

### Beispiel 3: Verbinden von Containern mit einem Netzwerk

```bash
docker run -d --name container1 --network my_network nginx
docker run -d --name container2 --network my_network nginx
```

Diese Befehle starten zwei Container (container1 und container2) und verbinden sie mit dem zuvor erstellten Netzwerk "my_network".

### Beispiel 4: Anzeigen von Netzwerkdetails

```bash
docker network inspect my_network
```

Dieser Befehl zeigt detaillierte Informationen über das Netzwerk "my_network" an, einschließlich der zugehörigen Container und Konfigurationen.

### Beispiel 5: Löschen eines Docker-Netzwerks

```bash
docker network rm my_network
```

Dieser Befehl löscht das Docker-Netzwerk mit dem Namen "my_network".

## Docker: Kommunikation zwischen Containern über Docker-Netzwerke

Docker ermöglicht die einfache Bereitstellung und Verwaltung von Containern, und Docker-Netzwerke bieten eine Möglichkeit für Container, miteinander zu kommunizieren. Im Folgenden sind einige grundlegende Konzepte und Beispiele zur Kommunikation zwischen Containern über Docker-Netzwerke:

### Beispiel 1: Erstellen eines Docker-Netzwerks

```bash
docker network create my_network
```

Mit diesem Befehl wird ein Docker-Netzwerk mit dem Namen my_network erstellt. Container können diesem Netzwerk hinzugefügt werden, um miteinander zu kommunizieren.

### Beispiel 2: Starten von Containern im Docker-Netzwerk

```bash
docker run -d --name container1 --network my_network my_image1
docker run -d --name container2 --network my_network my_image2
```

Hier werden zwei Container (container1 und container2) gestartet und dem zuvor erstellten Docker-Netzwerk my_network hinzugefügt. Die Container verwenden jeweils unterschiedliche Images (my_image1 und my_image2).

### Beispiel 3: Kommunikation zwischen Containern im Docker-Netzwerk

```bash
docker exec container1 ping container2
```

Mit diesem Befehl kann der Container container1 den Container container2 im Docker-Netzwerk my_network erreichen. Dies ermöglicht die Kommunikation zwischen den Containern über das Netzwerk.

### Beispiel 4: Verwendung von Docker-Compose für die Netzwerkkonfiguration

```yaml
version: '3'
services:
  service1:
    image: my_image1
    networks:
      - my_network
  service2:
    image: my_image2
    networks:
      - my_network
networks:
  my_network:
```

In dieser Docker-Compose-Datei wird definiert, wie Container miteinander kommunizieren können. Beide Dienste (service1 und service2) sind Teil des Netzwerks my_network, was es ihnen ermöglicht, miteinander zu interagieren.