## Kubernetes: Skalierung und automatische Verteilung - Ein Überblick über DaemonSets

Kubernetes bietet leistungsstarke Funktionen zur Skalierung und Verteilung von Anwendungen. Eine spezielle Ressource dafür sind DaemonSets, die sicherstellen, dass alle (oder bestimmte) Nodes eine Kopie eines Pods ausführen. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in die Verwendung von DaemonSets in Kubernetes:

### DaemonSets

Ein DaemonSet sorgt dafür, dass eine Kopie eines Pods auf allen oder ausgewählten Nodes im Cluster läuft. Dies ist nützlich für Anwendungen, die auf jeder Node präsent sein müssen, wie Log- oder Monitoring-Agenten.

#### Beispiel 1: Einfaches DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: simple-daemonset
spec:
  selector:
    matchLabels:
      name: simple-daemonset
  template:
    metadata:
      labels:
        name: simple-daemonset
    spec:
      containers:
      - name: simple-daemonset-container
        image: busybox
        args:
        - /bin/sh
        - -c
        - while true; do echo "DaemonSet läuft"; sleep 60; done
```

In diesem Beispiel wird ein einfaches DaemonSet erstellt, das einen Pod auf jeder Node startet. Der Container im Pod führt eine Endlosschleife aus und gibt alle 60 Sekunden eine Nachricht aus.

### Skalierung
DaemonSets skalieren automatisch mit der Anzahl der Nodes im Cluster. Wenn eine neue Node zum Cluster hinzugefügt wird, erstellt Kubernetes automatisch eine neue Pod-Instanz des DaemonSets auf dieser Node.

#### Beispiel 2: DaemonSet mit Node-Selector
Manchmal möchten Sie DaemonSets nur auf bestimmten Nodes laufen lassen. Dies kann mit nodeSelector erreicht werden.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: selective-daemonset
spec:
  selector:
    matchLabels:
      name: selective-daemonset
  template:
    metadata:
      labels:
        name: selective-daemonset
    spec:
      nodeSelector:
        disktype: ssd
      containers:
      - name: selective-daemonset-container
        image: busybox
        args:
        - /bin/sh
        - -c
        - while true; do echo "DaemonSet auf SSD Nodes"; sleep 60; done

```

In diesem Beispiel wird das DaemonSet nur auf Nodes mit dem Label disktype=ssd ausgeführt.

### Tolerations und Node Affinity
DaemonSets können auch so konfiguriert werden, dass sie auf Nodes mit bestimmten Taints oder Affinitäten laufen.

#### Beispiel 3: DaemonSet mit Tolerations

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: tolerations-daemonset
spec:
  selector:
    matchLabels:
      name: tolerations-daemonset
  template:
    metadata:
      labels:
        name: tolerations-daemonset
    spec:
      tolerations:
      - key: "example-key"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
      - name: tolerations-daemonset-container
        image: busybox
        args:
        - /bin/sh
        - -c
        - while true; do echo "DaemonSet auf Nodes mit Tolerations"; sleep 60; done

```

In diesem Beispiel wird das DaemonSet auf Nodes ausgeführt, die den Taint example-key haben.