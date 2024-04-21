## Kubernetes: Zugriffskontrolle und Cluster-Erweiterungen

Kubernetes ist eine leistungsstarke Plattform für die Container-Orchestrierung, die eine Vielzahl von Funktionen zur Zugriffskontrolle und Cluster-Erweiterungen bietet. Hier sind einige wichtige Konzepte und Techniken zur Zugriffskontrolle sowie Erweiterungen für Kubernetes-Cluster:

### Rollenbasierte Zugriffskontrolle (RBAC)

Die rollenbasierte Zugriffskontrolle (RBAC) in Kubernetes ermöglicht es Administratoren, granulare Zugriffsrichtlinien für Benutzer und Dienste innerhalb des Clusters festzulegen. Mit RBAC können Berechtigungen auf Namespace- und Ressourcenebene zugewiesen werden.

### Service Accounts

Service Accounts sind Identitäten, die von Pods verwendet werden, um mit anderen Ressourcen im Kubernetes-Cluster zu interagieren. Sie werden verwendet, um die Berechtigungen und den Zugriff von Pods auf andere Ressourcen zu steuern.

### Monitoring und Logging

Monitoring und Logging sind wesentliche Erweiterungen für Kubernetes-Cluster, um die Leistung, Verfügbarkeit und Sicherheit der Anwendungen zu überwachen. Tools wie Prometheus und Grafana bieten umfassende Monitoring-Lösungen, während Fluentd und Elasticsearch für das zentrale Protokollieren und Analysieren von Protokollen verwendet werden können.

### Beispiel: RBAC-Richtlinie definieren

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

In diesem Beispiel wird eine RBAC-Richtlinie definiert, die einem Benutzer oder einer Gruppe Zugriff auf das Lesen von Pods in einem bestimmten Namespace ermöglicht.

### Beispiel: Monitoring mit Prometheus und Grafana

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: example-app
  namespace: default
  labels:
    team: frontend
spec:
  selector:
    matchLabels:
      app: example-app
  endpoints:
  - port: web
```

Dieses Beispiel zeigt die Definition eines ServiceMonitors für eine Beispielanwendung. Prometheus verwendet ServiceMonitors, um Metriken von Anwendungen zu sammeln und zu aggregieren.