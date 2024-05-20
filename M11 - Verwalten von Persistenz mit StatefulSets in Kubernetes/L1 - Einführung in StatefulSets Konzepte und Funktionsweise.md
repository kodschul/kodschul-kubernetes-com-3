## Kubernetes: Einführung in StatefulSets: Konzepte und Funktionsweise

StatefulSets in Kubernetes sind eine Ressource für die Verwaltung von zustandsbehafteten Anwendungen. Sie gewährleisten stabile Netzwerk-Identitäten und Speicher, wodurch die Verwaltung von Anwendungen, die persistente Daten benötigen, erleichtert wird. Im Folgenden werden grundlegende Konzepte und Beispiele zur Einführung in StatefulSets vorgestellt.

### Konzepte von StatefulSets

1. **Stabile Netzwerk-Identität**: Jeder Pod in einem StatefulSet erhält einen eindeutigen und stabilen Hostnamen, der auch nach Neustarts erhalten bleibt.
2. **Stabiler Speicher**: Jeder Pod kann auf persistenten Speicher zugreifen, der auch nach dem Löschen und Neustarten des Pods bestehen bleibt.
3. **Ordnungsgemäße Bereitstellung und Skalierung**: Pods werden in einer festgelegten Reihenfolge erstellt, skaliert und gelöscht.
4. **Ordnungsgemäße Updates**: StatefulSets ermöglichen Rolling Updates mit der Garantie, dass die Reihenfolge beibehalten wird.

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
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

In diesem Beispiel definiert das StatefulSet web drei Replikas des Nginx-Containers. Jeder Pod hat Zugriff auf ein eigenes PersistentVolume, das durch das volumeClaimTemplates-Feld definiert wird.

### Beispiel 2: StatefulSet mit stabiler Netzwerk-Identität

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
---
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
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi

```
