# Prometheus Setup und Autoskalierung in Kubernetes (Docker Desktop)

## Voraussetzungen

- **Docker Desktop** mit aktiviertem Kubernetes
- **kubectl** (Kubernetes CLI) installiert und konfiguriert
- **Helm** (optional, aber empfohlen für eine einfache Installation)

### 1. Kubernetes Cluster mit Docker Desktop einrichten

1. **Kubernetes auf Docker Desktop aktivieren**:

   - Öffne Docker Desktop und gehe zu **Settings** > **Kubernetes** und aktiviere Kubernetes.
   - Warte, bis Kubernetes gestartet ist.

2. **kubectl konfigurieren**:
   - Stelle sicher, dass kubectl auf das Docker Desktop Kubernetes Cluster zugreifen kann:
     ```bash
     kubectl config use-context docker-desktop
     ```

### 2. Prometheus mit Helm installieren

#### Schritt 1: Helm installieren

Falls **Helm** noch nicht installiert ist, kannst du es hier herunterladen und installieren:

- [Helm installieren](https://helm.sh/docs/intro/install/)

#### Schritt 2: Helm-Repository für Prometheus hinzufügen

Füge das **Prometheus-Community-Helm-Chart** hinzu:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

#### Schritt 3: Prometheus installieren

Installiere Prometheus und Grafana:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack
```

Dieser Befehl erstellt Prometheus, Grafana und andere dazugehörige Komponenten wie den **Alertmanager**.

#### Schritt 4: Überprüfe die Installation

Überprüfe, ob Prometheus und Grafana erfolgreich laufen:

```bash
kubectl get pods -n default
```

### 3. Zugriff auf Prometheus und Grafana

- **Prometheus**:

  ```bash
  kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
  ```

  Gehe zu `http://localhost:9090` in deinem Browser, um Prometheus zu erreichen.

- **Grafana**:
  ```bash
  kubectl port-forward svc/prometheus-kube-prometheus-grafana 3000:80
  ```
  Gehe zu `http://localhost:3000`, um das Grafana-Dashboard zu erreichen. Standard-Login: `admin`/`prom-operator`.

### 4. Flask-App für Prometheus-Metriken einrichten

Installiere das **Prometheus Python Client** in deiner Flask-App:

```txt
prometheus_client==0.11.0
```

Modifiziere deine Flask-App, um Metriken zu exponieren:

```python
from flask import Flask
from prometheus_client import Counter, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint'])

@app.route('/')
def hello_world():
    REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
    return 'Hello, Kubernetes Autoscaling with Flask!'

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; version=0.0.4'}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

### 5. Konfiguration von Prometheus zum Scrapen der Flask-Metriken

Erstelle oder bearbeite die **Prometheus-Konfigurationsdatei (`prometheus.yml`)** und stelle sicher, dass Prometheus die Flask-App-Metriken abruft:

```yaml
scrape_configs:
  - job_name: "flask-app"
    static_configs:
      - targets: ["flask-app-service:5000"] # Ersetze dies mit dem tatsächlichen Service-Host
```

### 6. Horizontal Pod Autoscaler (HPA) für Traffic-Last einrichten

Verwende **Prometheus Adapter**, um benutzerdefinierte Metriken für den HPA verfügbar zu machen.

#### Schritt 1: Prometheus Adapter installieren

```bash
helm install prometheus-adapter prometheus-community/prometheus-adapter
```

#### Schritt 2: HPA-Ressource für Traffic-basierte Skalierung

Erstelle eine **HPA-Ressource**, die auf der Anzahl der Anfragen basiert:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: flask-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: flask-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: External
      external:
        metric:
          name: request_count
          selector:
            matchLabels:
              method: "GET"
        target:
          type: Value
          value: "1000" # 1000 Anfragen pro Sekunde als Schwellenwert
```

#### Schritt 3: Überwache die Skalierung

Überprüfe, ob die Pods korrekt skaliert werden:

```bash
kubectl get pods
```

### Beispiel für die Triggerung neuer Instanzen basierend auf Traffic:

- Um das Autoscaling zu testen, generiere Traffic zu deiner Flask-App:

  ```bash
  ab -n 10000 -c 10 http://<dein-service-url>/
  ```

- Überwache, ob Prometheus die Metriken erfasst und ob der HPA neue Instanzen basierend auf der Traffic-Last hinzufügt.

### 7. Metriken überwachen und anpassen

Du kannst **Prometheus** verwenden, um Metriken zu überwachen, die Anzahl der Anfragen zu überprüfen und dann die Skalierung von Pods basierend auf diesen Daten zu steuern.
