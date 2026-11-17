# Lab 2.2 – Übung: Lokales Cluster starten

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — es entsteht das lokale Cluster `docker-desktop`, in dem ab Lab 2.4 die Hello-App läuft.

## Vorbereitung

- Docker Desktop läuft (`Engine running`); Terminal öffnen (macOS/Linux: Terminal, Windows: Git Bash).
- Starter und Arbeitsdatei: keine, alle Schritte sind Befehle und Klicks in Docker Desktop.
- Wurde das Cluster schon beim [Setup](../../00-setup-and-installation.md#kubernetes-in-docker-desktop-einschalten) erstellt, Aufgabe 1 nur prüfen.

## Aufgaben

1. Erstelle in Docker Desktop das Cluster: **Kubernetes** > **Create cluster** > Typ **Kubeadm** > **Create**. Warte, bis die Statusleiste `Kubernetes running` zeigt.
2. Prüfe mit `kubectl version`, dass Client und Server antworten und höchstens eine Minor-Version auseinanderliegen.
3. Zeige mit `kubectl get nodes` den Node an und mit `kubectl get nodes -o wide` zusätzlich seine IP, sein Betriebssystem und seine Container-Runtime.
4. Zeige mit `kubectl config get-contexts` alle Kontexte an und prüfe mit `kubectl config current-context`, dass `docker-desktop` aktiv ist; wechsle bei Bedarf mit `kubectl config use-context docker-desktop`.
5. Zeige mit `kubectl config view --minify` die kubeconfig des aktuellen Kontexts an und finde darin die Adresse des API-Servers (`server:`).

## Checkpoint

- `kubectl version` zeigt `Client Version` und `Server Version`, beide 1.35 oder neuer.
- `kubectl get nodes` zeigt `docker-desktop` mit `STATUS Ready` und `ROLES control-plane`.
- In `kubectl config get-contexts` steht der Stern `*` vor `docker-desktop`.
- `kubectl config view --minify` zeigt `server: https://kubernetes.docker.internal:6443` und statt Zertifikaten `DATA+OMITTED`.

## Abschlusskriterien

- Der Node `docker-desktop` ist `Ready`, und `kubectl` spricht mit diesem Cluster.

## Erweiterung

Zeige mit `kubectl cluster-info` die Adresse des API-Servers und des Cluster-DNS an. Öffne danach die Datei `~/.kube/config` in VS Code (`code ~/.kube/config`) und vergleiche sie mit der Ausgabe von `kubectl config view --minify`; ändere darin nichts.

## Fallback

- Kubernetes startet in Docker Desktop nicht: einmal **Reset cluster** versuchen; sonst minikube oder kind wie im [Setup](../../00-setup-and-installation.md#fallback-minikube-oder-kind) beschrieben. Der Node heißt dann `minikube` bzw. `kurs-control-plane`, der Kontext `minikube` bzw. `kind-kurs`; die übrigen Aufgaben gelten unverändert.
