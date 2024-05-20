## Kubernetes: Anwendungsbeispiele Einsatzszenarien für DaemonSets in Kubernetes

DaemonSets in Kubernetes stellen sicher, dass eine Kopie eines Pods auf jeder Node im Cluster ausgeführt wird. Dies ist besonders nützlich für Anwendungen, die eine Node-spezifische Konfiguration oder Überwachung erfordern. Im Folgenden sind einige Anwendungsbeispiele und Einsatzszenarien für DaemonSets in Kubernetes:

### Beispiel 1: Überwachung von Nodes

DaemonSets eignen sich hervorragend für Überwachungsanwendungen, die Metriken von allen Nodes im Cluster sammeln.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      name: node-exporter
  template:
    metadata:
      labels:
        name: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          hostPort: 9100
```

In diesem Beispiel wird der node-exporter von Prometheus auf jeder Node im Cluster ausgeführt, um Metriken zu sammeln und auf Port 9100 bereitzustellen.

### Beispiel 2: Logging-Agent
DaemonSets können verwendet werden, um einen Logging-Agenten auf jeder Node zu betreiben, der Log-Daten sammelt und an ein zentrales Log-Management-System sendet.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:latest
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log

```

In diesem Beispiel wird Fluentd als DaemonSet auf jeder Node ausgeführt und sammelt Logs aus dem Verzeichnis /var/log.

### Beispiel 3: Netzwerkkonfiguration
DaemonSets sind ideal für Anwendungen, die Netzwerk-Konfigurationen oder DNS-Dienste bereitstellen müssen.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  template:
    metadata:
      labels:
        k8s-app: kube-proxy
    spec:
      containers:
      - name: kube-proxy
        image: k8s.gcr.io/kube-proxy:v1.21.0
        securityContext:
          privileged: true

```

In diesem Beispiel wird der kube-proxy als DaemonSet in jedem Node des Clusters bereitgestellt, um Netzwerkregeln zu verwalten und Load Balancing durchzuführen.

### Beispiel 4: Node-spezifische Dienste
DaemonSets können verwendet werden, um spezifische Dienste auf bestimmten Nodes bereitzustellen, zum Beispiel einen NFS-Server oder eine lokale Datenbank.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nfs-server
spec:
  selector:
    matchLabels:
      name: nfs-server
  template:
    metadata:
      labels:
        name: nfs-server
    spec:
      containers:
      - name: nfs-server
        image: gcr.io/google_containers/volume-nfs:0.8
        ports:
        - containerPort: 2049
          hostPort: 2049

```

In diesem Beispiel wird ein NFS-Server auf jeder Node im Cluster bereitgestellt, um Dateifreigaben anzubieten.