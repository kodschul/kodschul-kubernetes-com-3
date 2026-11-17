# Setup und Installation

Alle Übungen laufen auf dem eigenen Rechner: Docker Desktop stellt Container und ein lokales Kubernetes-Cluster bereit, dazu kommen `kubectl`, Helm, Headlamp und VS Code.
Die Installation gehört vor den ersten Kurstag; sie dauert etwa 30–45 Minuten, Downloads eingeschlossen.

## Software für den Kurs

| Software | Zweck im Kurs | Prüfen mit | Gebraucht ab |
| --- | --- | --- | --- |
| Docker Desktop (aktuell 4.99) | Container bauen und starten; lokales Kubernetes-Cluster | `docker version` | Lab 1.1 |
| Kubernetes in Docker Desktop (Provisioner **Kubeadm**) | lokales Ein-Node-Cluster `docker-desktop` | `kubectl get nodes` | Lab 2.2 |
| `kubectl` | Kommandozeilen-Werkzeug für Kubernetes; kommt mit Docker Desktop | `kubectl version` | Lab 2.2 |
| Headlamp (Desktop-App, aktuell 0.46) | grafische Ansicht des Clusters | App startet, zeigt `docker-desktop` | Lab 2.3 |
| Helm 4 (aktuell 4.3) | Paketmanager für Kubernetes | `helm version --short` | Lab 9.1 |
| VS Code mit Erweiterungen **Kubernetes** und **YAML** | Dockerfiles und Manifeste schreiben, YAML-Prüfung | Erweiterungen-Ansicht | Lab 1.3 |
| nur Windows: WSL 2 | Linux-Unterbau für Docker Desktop | `wsl --version` | Lab 1.1 |
| nur Windows: Git for Windows (Git Bash) | Kurs-Shell `bash` | `bash --version` | Lab 1.1 |

Stand der Versionen: 11/2026, vor Kursbeginn prüfen.

## Voraussetzungen am Rechner

- **Arbeitsspeicher:** 16 GB empfohlen (Docker Desktop selbst verlangt mindestens 8 GB unter Windows, 4 GB unter macOS).
- **Betriebssystem:** macOS in einer der drei neuesten Hauptversionen; Windows 10 22H2 oder Windows 11 23H2 und neuer, jeweils 64 Bit.
- **Virtualisierung:** im BIOS/UEFI eingeschaltet (Windows); auf Firmenrechnern kann eine Richtlinie sie sperren.
- **Rechte:** Docker Desktop lässt sich unter Windows ohne Administratorrechte installieren (Modus „Per-user", Standard); WSL 2 einschalten braucht einmalig Administratorrechte.
- **Netzwerk:** Zugriff auf `docker.io` (Docker Hub), `registry.k8s.io`, `github.com` und `ghcr.io`; hinter einem Firmen-Proxy muss Docker Desktop den Proxy kennen (**Settings > Resources > Proxies**).
- **Lizenz:** Docker Desktop ist für Firmen ab 250 Beschäftigten oder 10 Mio. USD Jahresumsatz kostenpflichtig ([Docker Desktop License](https://docs.docker.com/subscription/desktop-license/), Stand: 11/2026).
- **Linux-Rechner:** Docker Desktop für Linux bringt kein `kubectl` mit; der Host braucht cgroup v2 (Kubernetes ab 1.35). Einfacher ist dort der Fallback mit kind oder minikube (siehe unten).

Quellen: [Docker Desktop für Windows](https://docs.docker.com/desktop/setup/install/windows-install/), [Docker Desktop für Mac](https://docs.docker.com/desktop/setup/install/mac-install/), abgerufen am 17.11.2026.

## Kurs-Shell: bash

Alle Befehle in den Handouts sind für die Shell `bash` geschrieben.

| System | Shell | Öffnen |
| --- | --- | --- |
| macOS | Terminal (zsh versteht alle Kursbefehle) | **Programme > Dienstprogramme > Terminal** oder Terminal in VS Code |
| Linux | Terminal mit bash | Terminal oder Terminal in VS Code |
| Windows | **Git Bash** aus Git for Windows | Startmenü > **Git Bash**, oder in VS Code als Standard-Terminal |

Git Bash unter Windows einrichten:

1. Installiere Git for Windows von [git-scm.com](https://git-scm.com/downloads/win) oder per `winget install --id Git.Git -e` (PowerShell). Die vorgeschlagenen Standardoptionen passen.
2. Setze Git Bash in VS Code als Standard-Terminal: `Strg+Umschalt+P` > **Terminal: Select Default Profile** > **Git Bash**.
3. Schalte in Git Bash die automatische Pfad-Umwandlung ab. Git Bash schreibt sonst Linux-Pfade wie `/usr/share/nginx/html` in Windows-Pfade um, und Befehle wie `docker exec … ls /usr/share/nginx/html` schlagen fehl:

   ```bash
   echo 'export MSYS_NO_PATHCONV=1' >> ~/.bashrc
   source ~/.bashrc
   ```

## Docker Desktop installieren

| System | Weg |
| --- | --- |
| macOS | Installer von [docs.docker.com/desktop/setup/install/mac-install](https://docs.docker.com/desktop/setup/install/mac-install/) (Apple silicon oder Intel wählen) oder `brew install --cask docker-desktop` |
| Windows | Zuerst WSL 2: PowerShell **als Administrator** öffnen, `wsl --install` (neu) bzw. `wsl --update` (vorhanden), neu starten. Dann den Installer von [docs.docker.com/desktop/setup/install/windows-install](https://docs.docker.com/desktop/setup/install/windows-install/) ausführen, Backend **WSL 2** belassen. |

Nach dem ersten Start fragt Docker Desktop nach einer Anmeldung; sie ist für den Kurs optional, hilft aber gegen das Pull-Limit (siehe [Docker-Hub-Limit](#docker-hub-limit-und-docker-login)).

<img src="https://docs.docker.com/get-started/docker-concepts/running-containers/images/published-ports.webp" alt="Docker Desktop Dashboard: links die Navigation mit Containers, Images, Volumes und Kubernetes, rechts ein laufender Container mit Port 8080:80, unten die Statusleiste mit Engine running und Kubernetes running" width="640">

_Quelle: Docker Inc., „Publishing and exposing ports" (https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/), abgerufen am 17.11.2026._

Das Dashboard zeigt links die Ansichten **Containers**, **Images**, **Volumes** und **Kubernetes**; die Statusleiste unten meldet `Engine running` und nach dem nächsten Schritt `Kubernetes running`.

## Kubernetes in Docker Desktop einschalten

1. Öffne das Docker Desktop Dashboard und wähle links **Kubernetes**.
2. Wähle **Create cluster**.
3. Wähle als Cluster-Typ **Kubeadm** (ein Node, Version von Docker Desktop festgelegt).
4. Bestätige mit **Create** und warte, bis die Statusleiste `Kubernetes running` zeigt (1–3 Minuten, beim ersten Mal Downloads).

Docker Desktop installiert dabei `kubectl` mit und legt den Kontext `docker-desktop` in `~/.kube/config` an.

### Provisioner Kubeadm für selbst gebaute Images

Nur der Kubeadm-Cluster arbeitet mit dem Image-Speicher von Docker Desktop zusammen. Images, die im Kurs mit `docker build` entstehen, sind damit sofort im Cluster nutzbar, ohne Registry. Der kind-Cluster kann mehrere Nodes und eine wählbare Version, braucht dafür aber den containerd-Image-Store.

Bedienung Stand: 11/2026, vor Kursbeginn prüfen; Quelle: [Explore the Kubernetes view](https://docs.docker.com/desktop/use-desktop/kubernetes/), abgerufen am 17.11.2026.

## kubectl

- Kommt mit Docker Desktop; unter macOS liegt es in `/usr/local/bin/kubectl`, unter Windows im Programmordner von Docker Desktop (`…\resources\bin\kubectl.exe`), jeweils im Suchpfad.
- `kubectl` darf höchstens eine Minor-Version vom Cluster abweichen (Client 1.36 passt zu Cluster 1.35–1.37).
- Ein älteres `kubectl` aus Homebrew oder Chocolatey kann das von Docker Desktop überdecken: `which kubectl` zeigt, welches aufgerufen wird.

## Headlamp

Headlamp ist die grafische Oberfläche für Kubernetes und Nachfolger des archivierten Kubernetes Dashboard. Die Desktop-App liest dieselbe Datei `~/.kube/config` wie `kubectl`.

| System | Installation |
| --- | --- |
| macOS | `brew install --cask headlamp` oder `.dmg` von [github.com/kubernetes-sigs/headlamp/releases](https://github.com/kubernetes-sigs/headlamp/releases) |
| Windows | `winget install headlamp` (PowerShell) oder `.exe` von der Release-Seite |
| Linux | `flatpak install io.kinvolk.Headlamp` |

<img src="https://raw.githubusercontent.com/kubernetes-sigs/headlamp/screenshots/screenshots/home.png" alt="Headlamp-Startseite: Kacheln und Tabelle aller Cluster aus der kubeconfig, darunter docker-desktop, mit Status und Kubernetes-Version" width="600">

_Quelle: Headlamp README (https://github.com/kubernetes-sigs/headlamp), Apache-2.0, abgerufen am 17.11.2026._

Nach dem Start listet die Startseite alle Cluster aus der kubeconfig; `docker-desktop` muss dort mit Status `Active` erscheinen. Quelle: [Headlamp Desktop-Installation](https://headlamp.dev/docs/latest/installation/desktop/), Stand: 11/2026.

## Helm 4

| System | Installation |
| --- | --- |
| macOS | `brew install helm` |
| Windows | `winget install Helm.Helm` (PowerShell), danach Git Bash neu öffnen |
| Linux | Skript oder Paket laut [helm.sh/docs/intro/install](https://helm.sh/docs/intro/install/) |

`helm version --short` muss mit `v4.` beginnen. Ein vorhandenes Helm 3 reicht nicht: Modul 9 nutzt Optionen von Helm 4.

## VS Code mit Kubernetes- und YAML-Erweiterung

Installiere VS Code von [code.visualstudio.com](https://code.visualstudio.com/) und danach die beiden Erweiterungen, entweder über die Erweiterungen-Ansicht (`Strg+Umschalt+X`, macOS `Cmd+Shift+X`) oder im Terminal:

```bash
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension redhat.vscode-yaml
```

| Erweiterung | Nutzen im Kurs |
| --- | --- |
| Kubernetes (Microsoft) | Cluster-Baum in der Seitenleiste, Vorlagen und Hilfe für Manifeste |
| YAML (Red Hat) | prüft Einrückung und Felder von Kubernetes-Manifesten beim Tippen |

## Kursdateien holen

Beide Wege führen zum selben Ordner; Git ist dafür nicht nötig.

| Weg | Schritte |
| --- | --- |
| ZIP | [ZIP herunterladen](https://github.com/kodschul/kodschul-kubernetes-com-3/archive/refs/heads/main.zip), entpacken, z. B. nach `~/kurs/` |
| git | `git clone https://github.com/kodschul/kodschul-kubernetes-com-3.git ~/kurs/kodschul-kubernetes-com-3` |

Öffne den entpackten Ordner danach in VS Code (**File > Open Folder**) und im Terminal den Unterordner `project/`:

```bash
cd ~/kurs/kodschul-kubernetes-com-3/project    # beim ZIP heißt der Ordner kodschul-kubernetes-com-3-main
ls
```

```text
build-images.sh  examples  playground  starters  variants
```

| Ordner | Inhalt |
| --- | --- |
| `playground/` | eigener Arbeitsbereich: Quellcode der Hello-App, ab Lab 2.4 eigene Manifeste in `playground/k8s/` |
| `starters/` | unvollständige Startdateien der Übungen zum Kopieren in `playground/` |
| `examples/<modul>/<lab>/` | fertiger Stand jedes Labs zum Vergleichen und Wiederherstellen |
| `variants/` | absichtlich fehlerhafte Manifeste für die Fehlersuche-Labs |

Alle Befehle in den Übungen laufen aus dem Ordner `project/`, wenn nichts anderes dabeisteht.

## Installation prüfen

Führe die Befehle in der Kurs-Shell aus. Versionsnummern dürfen abweichen; wichtig ist, dass jeder Befehl antwortet.

```bash
docker version --format 'Client {{.Client.Version}} / Server {{.Server.Version}}'
docker run --rm hello-world
kubectl version
kubectl get nodes
kubectl config current-context
helm version --short
```

Erwartete Ausgabe (gekürzt):

```text
Client 29.x.x / Server 29.x.x
Hello from Docker!
This message shows that your installation appears to be working correctly.
…
Client Version: v1.3x.x
Kustomize Version: v5.x.x
Server Version: v1.3x.x
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   5m    v1.3x.x
docker-desktop
v4.3.2+g…
```

Danach Headlamp starten: die Startseite zeigt `docker-desktop` mit Status `Active`.

## Docker-Hub-Limit und docker login

Docker Hub begrenzt Downloads (Pulls) von Images je 6 Stunden:

| Nutzer | Pulls je 6 Stunden |
| --- | --- |
| ohne Anmeldung | 100 je IPv4-Adresse |
| mit kostenlosem Docker-Konto | 200 je Konto |

In einem Firmennetz teilen sich oft alle Rechner eine öffentliche IP-Adresse; dann ist das anonyme Limit schnell aufgebraucht und `docker pull` meldet `toomanyrequests`. Abhilfe: ein kostenloses Konto auf [hub.docker.com](https://hub.docker.com/) anlegen und anmelden.

```bash
docker login
```

Der Befehl zeigt einen Code und eine Adresse; im Browser bestätigen, danach meldet das Terminal `Login Succeeded`. Alternativ in Docker Desktop oben rechts **Sign in** wählen. Quelle: [Docker Hub Pull-Limits](https://docs.docker.com/docker-hub/usage/pulls/), Stand: 11/2026.

## Fallback: minikube oder kind

Wenn Docker Desktop nicht erlaubt ist oder Kubernetes darin nicht startet, läuft der Kurs auch mit minikube oder kind. Beide brauchen eine Container-Engine (Docker Engine, Docker Desktop oder Podman).

| | minikube (v1.39) | kind (v0.33) |
| --- | --- | --- |
| Installation | `brew install minikube` / `winget install Kubernetes.minikube` | `brew install kind` / `winget install Kubernetes.kind` |
| Cluster starten | `minikube start` | `kind create cluster --name kurs` |
| Kontext | `minikube` | `kind-kurs` |
| Zustand prüfen | `minikube status` | `kubectl get nodes` |
| anhalten / löschen | `minikube stop` / `minikube delete` | – / `kind delete cluster --name kurs` |
| lokales Image ins Cluster laden | `minikube image load hello-backend:v1` | `kind load docker-image hello-backend:v1 --name kurs` |
| `LoadBalancer`-Services (Lab 5.2) | `minikube tunnel` in einem zweiten Terminal | nicht ohne Zusatz; `kubectl port-forward` nutzen |

Unterschied zu Docker Desktop: Selbst gebaute Images (ab Lab 1.3) sind dort nicht automatisch im Cluster. Nach jedem `docker build` das Image mit der Zeile aus der Tabelle laden, sonst meldet der Pod `ErrImageNeverPull`. Installationsbefehle Stand: 11/2026, vor Kursbeginn prüfen; Quellen: [minikube](https://minikube.sigs.k8s.io/docs/start/), [kind](https://kind.sigs.k8s.io/docs/user/quick-start/).

## Typische Installationsprobleme

| Symptom | Ursache | Lösung |
| --- | --- | --- |
| `Cannot connect to the Docker daemon` / `failed to connect to the docker API` | Docker Desktop läuft nicht | Docker Desktop starten, warten bis `Engine running` |
| Windows: „WSL 2 installation is incomplete" oder „Virtualization support not detected" | WSL fehlt oder Virtualisierung aus | PowerShell als Administrator: `wsl --install` bzw. `wsl --update`; Virtualisierung im BIOS/UEFI einschalten |
| `kubectl: command not found` | Kubernetes in Docker Desktop noch nicht erstellt, oder Terminal vor der Installation geöffnet | Schritt „Kubernetes einschalten" ausführen, Terminal neu öffnen |
| `The connection to the server localhost:8080 was refused` | keine kubeconfig oder falscher Kontext | `kubectl config use-context docker-desktop` |
| `kubectl get nodes` zeigt `NotReady` | Cluster startet noch | 1–2 Minuten warten; sonst in Docker Desktop **Kubernetes > Reset cluster** |
| Kubernetes startet nicht („Starting…" bleibt) | zu wenig Speicher für die Docker-VM, Proxy blockiert Downloads | **Settings > Resources** mindestens 6 GB Speicher; Proxy unter **Settings > Resources > Proxies** eintragen |
| `toomanyrequests: You have reached your pull rate limit` | Docker-Hub-Limit der gemeinsamen IP erreicht | `docker login` (siehe oben) |
| ab Lab 3.1: Pod meldet `ErrImageNeverPull` | Cluster-Typ kind statt Kubeadm, oder Images fehlen (neuer Rechner, Reset) | Docker Desktop > **Kubernetes** > **Edit cluster** > **Kubeadm**; fehlende Images mit `bash build-images.sh` im Ordner `project/` bauen |
| Git Bash: `ls: cannot access 'C:/Program Files/Git/usr/share/…'` | Pfad-Umwandlung von Git Bash | `export MSYS_NO_PATHCONV=1` in `~/.bashrc` (siehe Kurs-Shell) |
| Git Bash: `the input device is not a TTY` bei `docker exec -it` | Git-Bash-Fenster (mintty) ohne echtes Terminal | Befehl mit `winpty` beginnen: `winpty docker exec -it …`, oder das Terminal in VS Code nutzen |
| `helm version` zeigt `v3.…` | altes Helm im Suchpfad | Helm 4 installieren, `which helm` prüfen, altes entfernen |
| Headlamp zeigt keinen Cluster | Headlamp vor dem Cluster gestartet | Headlamp neu starten; Cluster muss `Kubernetes running` zeigen |
| Port 8080 belegt (`port is already allocated`) | anderer Container oder Dienst nutzt den Port | `docker ps` prüfen, alten Container mit `docker rm -f <name>` entfernen |
