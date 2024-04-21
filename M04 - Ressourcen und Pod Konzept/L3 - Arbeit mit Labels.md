# Kubernetes: Flexibles Anwendungsdeployment und Arbeit mit Labels

Kubernetes ist eine leistungsstarke Plattform zur Verwaltung von Container-Anwendungen in einer Cloud-Umgebung. Eine der Kernfunktionen von Kubernetes ist das flexible Anwendungsdeployment und die Möglichkeit, Ressourcen mithilfe von Labels zu organisieren und zu steuern. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele für die Arbeit mit Labels in Kubernetes:

## Flexibles Anwendungsdeployment

### Beispiel 1: Deployment-Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
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
        image: nginx:latest
        ports:
        - containerPort: 80
```

Dieses Beispiel zeigt ein Kubernetes-Deployment-Manifest für eine Nginx-Anwendung. Das metadata.labels-Feld wird verwendet, um Labels für die Pods festzulegen, die durch dieses Deployment erstellt werden.

## Arbeit mit Labels
### Beispiel 2: Pods anhand von Labels abfragen
Um Pods basierend auf ihren Labels abzufragen, kann das kubectl get pods-Kommando mit dem --selector-Flag verwendet werden:

```bash
kubectl get pods --selector=app=nginx
```

Dieses Kommando gibt alle Pods zurück, die das Label app=nginx haben.

### Beispiel 3: Skalieren von Deployments basierend auf Labels
Um die Anzahl der Replikate eines Deployments basierend auf Labels zu skalieren, kann das kubectl scale-Kommando verwendet werden:

```bash
kubectl scale --replicas=5 deployment/nginx-deployment
```

Dieses Kommando skaliert das Deployment mit dem Namen nginx-deployment auf 5 Replikate.