# Lab 2.3 – Übung: Architektur eines Clusters

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — die Übung liest nur den Zustand des Clusters.

## Vorbereitung

- Cluster aus Lab 2.2 läuft: `kubectl get nodes` zeigt `docker-desktop` als `Ready`.
- Headlamp ist installiert ([Setup](../../00-setup-and-installation.md#headlamp)).
- Windows/Git Bash: `MSYS_NO_PATHCONV=1` ist gesetzt ([Setup](../../00-setup-and-installation.md#kurs-shell-bash)).
- Starter und Arbeitsdatei: keine.

## Aufgaben

1. Zeige mit `kubectl get pods -n kube-system -o wide` die Systemkomponenten an und ordne jeden Pod-Namen einer Komponente aus der Tabelle im Theorieteil zu (API-Server, etcd, Scheduler, Controller-Manager, kube-proxy, CoreDNS).
2. Prüfe die Gesundheit des API-Servers mit `kubectl get --raw /livez` und danach mit `kubectl get --raw '/livez?verbose'`; suche in der langen Ausgabe die Zeile zu etcd.
3. Zeige mit `kubectl api-resources` alle Objekttypen an und filtere die Liste mit `kubectl api-resources | grep -E "^(pods|nodes|namespaces) "` auf drei bekannte Typen.
4. Öffne Headlamp, wähle den Cluster `docker-desktop`, gehe zu **Workloads** > **Pods** und wähle oben den Namespace `kube-system`. Öffne dort den Pod `kube-scheduler-docker-desktop` und öffne seine Details und Logs.
5. Öffne in Headlamp die Ansicht des Nodes `docker-desktop` (Bereich **Cluster** > **Nodes**) und vergleiche Kubernetes-Version und Container-Runtime mit `kubectl get nodes -o wide`.

## Checkpoint

- Aufgabe 1 zeigt Pods für alle vier Control-Plane-Komponenten (`…-docker-desktop`), `kube-proxy-…` und zwei `coredns-…`, alle `Running`.
- `kubectl get --raw /livez` antwortet mit `ok`; die ausführliche Variante enthält `[+]etcd ok` und endet mit `livez check passed`.
- Aufgabe 3 zeigt drei Zeilen: `pods` (Kurzname `po`, `NAMESPACED true`), `nodes` (`no`, `false`), `namespaces` (`ns`, `false`).
- Headlamp zeigt dieselben Pods wie Aufgabe 1 und für den Node dieselbe Version wie `kubectl`.

## Abschlusskriterien

- Jede Komponente der Control Plane und des Nodes ist im eigenen Cluster gefunden, einmal mit `kubectl` und einmal in Headlamp.

## Erweiterung

Öffne in Headlamp die Ansicht **Map** und wähle den Namespace `kube-system`: Die Ansicht zeigt die Pods, ihren Node und weitere Objekte als Grafik. Lies danach mit `kubectl describe pod -n kube-system kube-scheduler-docker-desktop` den Abschnitt `Command:` und finde die Datei, aus der der Scheduler seine kubeconfig liest.

## Fallback

- Headlamp lässt sich nicht installieren: Aufgaben 4 und 5 mit `kubectl` lösen (`kubectl logs -n kube-system kube-scheduler-docker-desktop`, `kubectl describe node docker-desktop`) oder in Docker Desktop die Ansicht **Kubernetes** nutzen.
- minikube oder kind statt Docker Desktop: Die Pods heißen `…-minikube` bzw. `…-kurs-control-plane`; statt `storage-provisioner`/`vpnkit-controller` erscheinen dort andere Hilfs-Pods.
