# Lab 2.3 – Lösung: Architektur eines Clusters

## Aufgabe 1: Systemkomponenten

```bash
kubectl get pods -n kube-system -o wide
```

```text
NAME                                     READY   STATUS    RESTARTS   AGE   IP             NODE             …
coredns-7db6d8ff4d-k2m9x                 1/1     Running   0          25m   10.1.0.2       docker-desktop
coredns-7db6d8ff4d-wq5hl                 1/1     Running   0          25m   10.1.0.3       docker-desktop
etcd-docker-desktop                      1/1     Running   0          25m   192.168.65.3   docker-desktop
kube-apiserver-docker-desktop            1/1     Running   0          25m   192.168.65.3   docker-desktop
kube-controller-manager-docker-desktop   1/1     Running   0          25m   192.168.65.3   docker-desktop
kube-proxy-7xq2d                         1/1     Running   0          25m   192.168.65.3   docker-desktop
kube-scheduler-docker-desktop            1/1     Running   0          25m   192.168.65.3   docker-desktop
storage-provisioner                      1/1     Running   0          25m   10.1.0.4       docker-desktop
vpnkit-controller                        1/1     Running   0          25m   10.1.0.5       docker-desktop
```

| Pod | Komponente |
| --- | --- |
| `kube-apiserver-docker-desktop` | API-Server |
| `etcd-docker-desktop` | etcd |
| `kube-scheduler-docker-desktop` | Scheduler |
| `kube-controller-manager-docker-desktop` | Controller-Manager |
| `kube-proxy-…` | kube-proxy (einer je Node) |
| `coredns-…` (zwei) | CoreDNS, Namensauflösung |
| `storage-provisioner`, `vpnkit-controller` | Hilfsdienste von Docker Desktop (Speicher, Netzwerk) |

Die Control-Plane-Pods tragen den Node-Namen im Namen und nutzen die IP des Nodes (192.168.65.3), weil sie direkt im Netz des Nodes laufen. Das kubelet fehlt in der Liste: Es läuft als Programm auf dem Node und startet die anderen. Namen der Hilfs-Pods und IPs können je nach Docker-Desktop-Version abweichen.

## Aufgabe 2: Gesundheit des API-Servers

```bash
kubectl get --raw /livez
```

```text
ok
```

```bash
kubectl get --raw '/livez?verbose'
```

```text
[+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-apiserver-admission-initializer ok
…
livez check passed
```

`[+]etcd ok` heißt: Der API-Server erreicht seine Datenbank. Die Anführungszeichen um `'/livez?verbose'` verhindern, dass die Shell das `?` als Platzhalter deutet.

## Aufgabe 3: Objekttypen

```bash
kubectl api-resources | grep -E "^(pods|nodes|namespaces) "
```

```text
namespaces    ns     v1     false    Namespace
nodes         no     v1     false    Node
pods          po     v1     true     Pod
```

Spalten: Name, Kurzname (`kubectl get po` = `kubectl get pods`), API-Version, gehört zu einem Namespace (`true`/`false`), Objekttyp. Nodes und Namespaces gelten clusterweit, Pods liegen immer in einem Namespace. Ohne Filter listet der Befehl rund 60 Typen.

## Aufgabe 4: Headlamp

Headlamp > Startseite > `docker-desktop` > **Workloads** > **Pods**, oben im Feld **Namespaces** `kube-system` wählen. Die Liste zeigt dieselben neun Pods wie Aufgabe 1. Ein Klick auf `kube-scheduler-docker-desktop` zeigt Status, Node, IP, Container und Events; über das Symbol **Logs** erscheinen die Ausgaben des Schedulers, dieselben wie mit `kubectl logs -n kube-system kube-scheduler-docker-desktop`.

## Aufgabe 5: Node in Headlamp

Headlamp > **Cluster** > **Nodes** > `docker-desktop` zeigt unter anderem Kubelet-Version (`v1.37.x`), Container-Runtime, Betriebssystem, CPU und Speicher. Dieselben Werte liefert:

```bash
kubectl get nodes -o wide
```

Headlamp liest seine Daten über denselben API-Server wie `kubectl`; beide Ansichten zeigen deshalb immer denselben Stand.

## Erweiterung: Map und Scheduler-Befehl

Die **Map** zeigt den Node `docker-desktop` mit allen Pods aus `kube-system` als verbundene Kacheln.

```bash
kubectl describe pod -n kube-system kube-scheduler-docker-desktop
```

```text
…
    Command:
      kube-scheduler
      --authentication-kubeconfig=/etc/kubernetes/scheduler.conf
      --authorization-kubeconfig=/etc/kubernetes/scheduler.conf
      --bind-address=127.0.0.1
      --kubeconfig=/etc/kubernetes/scheduler.conf
      --leader-elect=true
…
```

Auch der Scheduler ist nur ein Client des API-Servers: Er liest seine Verbindung aus `/etc/kubernetes/scheduler.conf`, einer kubeconfig wie der aus Lab 2.2.
