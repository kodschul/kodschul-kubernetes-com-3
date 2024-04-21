# Kubernetes: Verwendung von Config Files, Arbeitsbereichen und CLI-Tools

Kubernetes ist eine Open-Source-Plattform zur Automatisierung der Bereitstellung, Skalierung und Verwaltung von containerisierten Anwendungen. Die Verwendung von Konfigurationsdateien, Arbeitsbereichen und CLI-Tools ist entscheidend für die effektive Verwaltung von Kubernetes-Clustern. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Verwendung von Kubernetes:

## Konfigurationsdateien

### Beispiel 1: Deployment-Konfiguration

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
        image: nginx:1.19.10
        ports:
        - containerPort: 80
```

In diesem Beispiel wird eine Kubernetes-Deployment-Konfiguration definiert, um eine Gruppe von Nginx-Containern bereitzustellen. Die Datei ist im YAML-Format verfasst und enthält Informationen wie die Anzahl der Replikate, den Container-Image-Namen und die Portzuordnung.

## Arbeitsbereiche

### Beispiel 2: Arbeiten mit Namespaces

```bash
# Erstellen eines neuen Namespaces
kubectl create namespace my-namespace

# Anzeigen aller Namespaces
kubectl get namespaces

# Wechseln des Arbeitsbereichs zu einem anderen Namespace
kubectl config set-context --current --namespace=my-namespace
```

In diesem Beispiel werden einige grundlegende Befehle zur Arbeit mit Kubernetes-Namespaces gezeigt. Namespaces ermöglichen die Segmentierung von Ressourcen in einem Kubernetes-Cluster und können verwendet werden, um Ressourcen nach Anwendung, Umgebung oder Team zu organisieren.

## CLI-Tools
### Beispiel 3: Verwendung von kubectl

```bash
# Anzeigen von Informationen über Pods im aktuellen Namespace
kubectl get pods

# Anzeigen von Informationen über Services
kubectl get services

# Anzeigen von Logs eines Pods
kubectl logs <pod-name>
```

Das Kubernetes Command Line Interface (kubectl) ist ein leistungsstarkes Werkzeug zur Interaktion mit Kubernetes-Clustern. Mit kubectl können Benutzer Ressourcen erstellen, verwalten und überwachen, sowie Diagnose- und Debugging-Aufgaben durchführen.