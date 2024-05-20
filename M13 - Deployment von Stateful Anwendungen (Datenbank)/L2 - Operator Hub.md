## Kubernetes: Deployment von Stateful Anwendungen (Datenbank): Operator Hub

In Kubernetes gibt es spezielle Werkzeuge und Ansätze für das Deployment von Stateful Anwendungen wie Datenbanken. Der Operator Hub bietet eine zentrale Sammlung von Kubernetes-Operatoren, die die Verwaltung und Automatisierung von Stateful Anwendungen erleichtern. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zum Deployment von Stateful Anwendungen mithilfe des Operator Hub:

### Was sind Kubernetes-Operatoren?

Kubernetes-Operatoren sind Softwarecontroller, die spezifisches Wissen über Anwendungen oder Services in Kubernetes integrieren. Sie automatisieren Aufgaben wie das Bereitstellen, Konfigurieren und Verwalten komplexer Anwendungen. Der Operator Hub ist eine Plattform zur Suche und Installation von Operatoren.

### Beispiel 1: Installation eines PostgreSQL-Operators über den Operator Hub

Der PostgreSQL-Operator ermöglicht das einfache Deployment und die Verwaltung von PostgreSQL-Datenbanken in Kubernetes.

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: postgresql-operator
  namespace: myproject
spec:
  channel: alpha
  name: postgresql-operator
  source: operatorhubio-catalog
  sourceNamespace: olm
```

Dieses YAML-Manifest demonstriert die Installation des PostgreSQL-Operators über den Operator Hub in einem Kubernetes-Cluster.

### Beispiel 2: Bereitstellung einer PostgreSQL-Datenbank mit dem PostgreSQL-Operator
Nach der Installation des PostgreSQL-Operators können PostgreSQL-Datenbanken einfach bereitgestellt werden.

```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: acid-minimal-cluster
spec:
  teamId: "acid"
  volume:
    size: 1Gi
  postgresql:
    version: "12"

```

Dieses Beispiel manifestiert die Bereitstellung einer PostgreSQL-Datenbank namens "acid-minimal-cluster" mit einer Speicherkapazität von 1 GB und PostgreSQL-Version 12.

### Beispiel 3: Überwachung und Skalierung von Stateful Anwendungen mit dem Prometheus-Operator
Der Prometheus-Operator ermöglicht die Überwachung von Kubernetes-Clustern und die Skalierung von Anwendungen basierend auf Metriken.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    prometheus: k8s
    role: alert-rules
  name: example
spec:
  groups:
  - name: example
    rules:
    - alert: HighPodMemory
      expr: sum(container_memory_usage_bytes) > 1e+09
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage in pod {{$labels.pod}}."

```

Dieses Beispiel zeigt die Definition einer Prometheus-Regel zur Überwachung von hohem Speicherverbrauch in Pods und zum Auslösen eines Warnalarms.