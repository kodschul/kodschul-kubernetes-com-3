## Kubernetes: Konfiguration von StatefulSets

StatefulSets in Kubernetes sind eine spezialisierte Ressource für die Verwaltung von zustandsbehafteten Anwendungen. Sie bieten eine garantierte Reihenfolge und Identität der Pods und sind besonders nützlich für Anwendungen wie Datenbanken oder verteilte Systeme. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Konfiguration von StatefulSets in Kubernetes:

### Grundlagen von StatefulSets

StatefulSets bieten:
- Stabilität von Netzwerk-Identität: Jeder Pod hat einen stabilen Hostnamen.
- Stabile, persistente Speicher: Jeder Pod kann über `PersistentVolumeClaims` auf seinen eigenen Speicher zugreifen.
- Ordnungsmäßige Erstellung und Skalierung: Pods werden in einer bestimmten Reihenfolge erstellt oder gelöscht.
- Ordentliche Updates: Updates erfolgen in einer geordneten Weise, die die Verfügbarkeit gewährleistet.

### Beispiel 1: Einfaches StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
          name: web
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

In diesem Beispiel wird ein einfaches StatefulSet mit drei Replikas einer Nginx-Anwendung erstellt. Jeder Pod erhält eine eigene PersistentVolumeClaim (PVC) namens www.

### Beispiel 2: StatefulSet mit Persistent Storage

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password"
  volumeClaimTemplates:
  - metadata:
      name: mysql-persistent-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi

```

In diesem Beispiel wird ein StatefulSet für eine MySQL-Datenbank erstellt. Jeder MySQL-Pod erhält eine eigene PersistentVolumeClaim für die Speicherung der Datenbankdateien.

### Beispiel 3: Headless Service für StatefulSet
Ein Headless Service wird benötigt, um den Pods in einem StatefulSet stabile Netzwerk-Identitäten zu verleihen.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx


```

Dieser Headless Service ermöglicht den Zugriff auf jeden Pod des StatefulSets über einen stabilen DNS-Eintrag.

### Beispiel 4: Ordentliche Skalierung und Updates
StatefulSets bieten Mechanismen für geordnete Skalierung und Updates.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.16.1
        ports:
        - containerPort: 80
          name: web

```

In diesem Beispiel wird die updateStrategy des StatefulSets auf RollingUpdate gesetzt, was sicherstellt, dass die Pods nacheinander aktualisiert werden, um die Verfügbarkeit zu gewährleisten.