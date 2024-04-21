# Kubernetes: Setup der Arbeitsumgebung und Nutzung der CLI

Kubernetes ist eine Open-Source-Plattform zur Automatisierung der Bereitstellung, Skalierung und Verwaltung containerisierter Anwendungen. Die Kubernetes-Befehlszeilenschnittstelle (CLI) ermöglicht es Entwicklern und Administratoren, mit Kubernetes-Clustern zu interagieren. Im Folgenden sind einige grundlegende Schritte zum Einrichten der Arbeitsumgebung und zur Nutzung der Kubernetes-CLI aufgeführt:

## Schritt 1: Installation von kubectl

`kubectl` ist das Hauptwerkzeug zum Interagieren mit Kubernetes-Clustern über die Befehlszeile. Es kann von der offiziellen Kubernetes-Website heruntergeladen und installiert werden oder über Paketmanager wie `brew`, `apt` oder `yum` installiert werden, je nach Betriebssystem.

### Installation unter macOS mit Homebrew:

```bash
brew install kubectl
```

### Installation unter Linux mit apt:

```bash
sudo apt-get update && sudo apt-get install -y kubectl
```

### Installation unter Windows mit Chocolatey:

```bash
choco install kubernetes-cli
```

### Schritt 2: Konfiguration von kubectl
Nach der Installation von kubectl muss die Konfiguration für den Zugriff auf Ihren Kubernetes-Cluster festgelegt werden. Dies erfolgt normalerweise durch das Herunterladen der Kubernetes-Konfigurationsdatei (kubeconfig) von Ihrem Cluster und das Festlegen des Umgebungsparameters KUBECONFIG, um auf diese Datei zu verweisen.

```bash
export KUBECONFIG=~/.kube/config
```

### Schritt 3: Verwendung von kubectl
Nachdem die Konfiguration abgeschlossen ist, können Sie kubectl verwenden, um mit Ihrem Kubernetes-Cluster zu interagieren. Hier sind einige grundlegende Befehle:

Cluster-Informationen anzeigen:

```bash
kubectl cluster-info
```

Nodes im Cluster anzeigen:

```bash
kubectl get nodes
```

Pods im Cluster anzeigen:

```bash
kubectl get pods
```

Erstellen eines Pods aus einer YAML-Datei:

```bash
kubectl apply -f example.yaml
```

Löschen eines Pods:

```bash
kubectl delete pod <pod_name>
```