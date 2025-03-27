#### Beispiel:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mein-deployment
spec:
  replicas: 3 # Anzahl der Pods
  selector:
    matchLabels:
      app: mein-app
  template:
    metadata:
      labels:
        app: mein-app
    spec:
      containers:
        - name: mein-container
          image: mein-image
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app: mein-app
              topologyKey: "kubernetes.io/hostname" # Jeder Pod auf einem anderen Knoten
```

### Erklärung:

- **affinity/podAntiAffinity** sorgt dafür, dass Pods auf unterschiedlichen Knoten (basierend auf `topologyKey: kubernetes.io/hostname`) geplant werden.
- **requiredDuringSchedulingIgnoredDuringExecution** stellt sicher, dass der Pod nur auf einem Knoten geplant wird, wenn dort noch kein anderer Pod mit dem gleichen Label läuft.

### 2. **Verwenden von Taints und Tolerationen**

Du kannst auch **Taints und Tolerationen** verwenden, um sicherzustellen, dass jeder Knoten nur einen Pod ausführt. Zuerst taintest du die Knoten und fügst dann die entsprechende Toleration in den Pods hinzu.

#### Schritt 1: Taint auf den Knoten anwenden

```bash
kubectl taint nodes <node-name> dedicated=unique:NoSchedule
```

#### Schritt 2: Toleration in der Pod-Definition hinzufügen

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mein-deployment
spec:
  replicas: 3 # Anzahl der Pods
  selector:
    matchLabels:
      app: mein-app
  template:
    metadata:
      labels:
        app: mein-app
    spec:
      containers:
        - name: mein-container
          image: mein-image
      tolerations:
        - key: "dedicated"
          operator: "Equal"
          value: "unique"
          effect: "NoSchedule"
```

### Erklärung:

- **Taints** verhindern, dass ein Pod auf einem Knoten geplant wird, es sei denn, der Pod hat eine passende **Toleration**.
- So wird sichergestellt, dass auf jedem Knoten genau ein Pod ausgeführt wird.
