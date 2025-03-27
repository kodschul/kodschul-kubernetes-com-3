# Do's und Don'ts in Kubernetes

## **Don'ts**

### 1. **Vermeide es, Container als root auszuführen**

Es ist wichtig, Container nicht als `root`-Benutzer auszuführen, um Sicherheitslücken zu vermeiden.

**Beispiel:**

```yaml
spec:
  securityContext:
    runAsUser: 1000 # Führe den Container als nicht-root Benutzer aus
```

### 2. **Keine fehlenden Ressourcenanforderungen und -limits verwenden**

Vermeide es, keine Ressourcenanforderungen und -limits zu definieren, da dies zu Ressourcenengpässen oder -verschwendung führen kann.

**Beispiel:**

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

### 3. **Keine einzige Replikation für kritische Anwendungen verwenden**

Vermeide es, für kritische Anwendungen nur eine einzige Replikation zu verwenden, da dies einen Single-Point-of-Failure (SPOF) verursachen kann.

**Beispiel:**

```yaml
spec:
  replicas: 3 # Mindestens 3 Replikas für Ausfallsicherheit
```

### 4. **Vermeide das Hard-Coding von Secrets im Anwendungscode**

Speichere keine Passwörter und geheimen Daten direkt im Anwendungscode.

**Beispiel:**
Verwende **Secrets**:

```bash
kubectl create secret generic db-password --from-literal=password=supersecret
```

### 5. **Pods ohne geeignete Strategien für Disruptionen ausführen**

Vermeide es, Pods ohne Pod-Disruption-Strategien zu betreiben, um mögliche Ausfälle bei Wartungsarbeiten zu vermeiden.

**Beispiel:**

```yaml
spec:
  podDisruptionBudget:
    minAvailable: 1
```

### 6. **Log-Management ignorieren**

Vermeide es, Logdaten zu ignorieren. Verwende zentrale Log-Management-Tools, um Logs zu sammeln und zu analysieren.

**Beispiel:**
Nutze **Fluentd** oder **Elasticsearch**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluentd.conf: |
    # Fluentd config here
```

### 7. **Pods manuell skalieren**

Vermeide es, Pods manuell zu skalieren. Verwende stattdessen den **Horizontal Pod Autoscaler (HPA)**, um die Skalierung automatisch basierend auf Metriken wie CPU oder Speicher vorzunehmen.

**Beispiel:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

### 8. **Services ohne Netzwerkschutz exponieren**

Vermeide es, Kubernetes-Services ohne Netzwerkschutz wie **Network Policies** oder **RBAC** öffentlich zugänglich zu machen.

**Beispiel:**
Verwende **Network Policies**:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-my-app
spec:
  podSelector:
    matchLabels:
      app: my-app
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: my-app
```

### 9. **Große Daten im Container-Dateisystem speichern**

Vermeide es, große Datenmengen im Container-Dateisystem zu speichern. Verwende stattdessen **Persistent Volumes (PV)**.

**Beispiel:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### 10. **Kubernetes-Updates ignorieren**

Vermeide es, die Kubernetes-Version zu ignorieren und keine regelmäßigen Updates durchzuführen.

**Beispiel:**
Nutze **`kubectl`** oder **Helm**, um sicherzustellen, dass dein Cluster aktuell bleibt:

```bash
kubectl version
helm upgrade
```

---

## **Do's**

### 1. **Verwende Namespaces zur Ressourcenspeicherung und -isolierung**

Nutze **Namespaces**, um verschiedene Umgebungen zu isolieren und Ressourcen effizient zu verwalten.

**Beispiel:**

```bash
kubectl create namespace production
```

### 2. **Ressourcenanforderungen und -limits festlegen**

Definiere **Ressourcenanforderungen** und **Limits**, um sicherzustellen, dass Pods ausreichend Ressourcen erhalten und die Cluster-Ressourcen effizient genutzt werden.

**Beispiel:**

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

### 3. **Rolling Updates für Deployments verwenden**

Nutze **Rolling Updates**, um sicherzustellen, dass deine Anwendung mit minimalen Ausfallzeiten aktualisiert wird.

**Beispiel:**

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

### 4. **Nutze `kubectl` effizient**

Verwende **`kubectl`**, um deine Pods und Cluster zu überwachen, Logs abzurufen und detaillierte Einblicke in den Cluster zu bekommen.

**Beispiel:**

```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

### 5. **Automatisiere Deployments mit CI/CD**

Automatisiere **Deployments** mit einem **CI/CD-Tool** wie Jenkins oder GitLab CI, um die Aktualisierungen zu vereinfachen.

**Beispiel:**

```groovy
pipeline {
    agent any
    stages {
        stage('Deploy') {
            steps {
                script {
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }
}
```

### 6. **Verwende den Horizontal Pod Autoscaler (HPA)**

Nutze den **Horizontal Pod Autoscaler (HPA)**, um die Anzahl der Pods basierend auf der Auslastung (z.B. CPU) automatisch zu skalieren.

**Beispiel:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

### 7. **Verwende ConfigMaps und Secrets für Konfigurationsmanagement**

Verwende **ConfigMaps** und **Secrets**, um Konfigurationen und geheime Daten zu speichern.

**Beispiel:**
Erstelle ein ConfigMap:

```bash
kubectl create configmap app-config --from-literal=key=value
```

Erstelle ein Secret:

```bash
kubectl create secret generic db-password --from-literal=password=mysecretpassword
```

### 8. **Verwende Network Policies zur Sicherung der Kommunikation**

Nutze **Network Policies**, um den Traffic zwischen den Pods zu steuern und die Sicherheit zu erhöhen.

**Beispiel:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-my-app
spec:
  podSelector:
    matchLabels:
      app: my-app
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: my-app
```

### 9. **Verwende Persistent Volumes für zustandsbehaftete Anwendungen**

Verwende **Persistent Volumes** (PV) und **Persistent Volume Claims** (PVC) für Anwendungen, die persistenten Speicher benötigen.

**Beispiel:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### 10. **Führe regelmäßig Updates von Kubernetes und deinen Workloads durch**

Stelle sicher, dass **Kubernetes** und deine Workloads immer auf dem neuesten Stand sind, um Sicherheitslücken zu schließen und von neuen Funktionen zu profitieren.

**Beispiel:**
Überprüfe die aktuelle Version von Kubernetes:

```bash
kubectl version
```

```bash
helm upgrade my-release prometheus-community/kube-prometheus-stack
```
