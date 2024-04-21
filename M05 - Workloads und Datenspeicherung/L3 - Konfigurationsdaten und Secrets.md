## Kubernetes: Bereitstellung von Konfigurationsdaten und Secrets: ConfigMaps und Secrets

In Kubernetes können Konfigurationsdaten und vertrauliche Informationen wie Passwörter, Schlüssel und Zertifikate als ConfigMaps und Secrets verwaltet werden. Diese Ressourcen ermöglichen es, Anwendungen in Kubernetes mit Umgebungsvariablen, Dateien oder Volumes zu konfigurieren. Im Folgenden sind einige grundlegende Konzepte und Beispiele zur Bereitstellung von Konfigurationsdaten und Secrets in Kubernetes:

### ConfigMaps

Eine ConfigMap in Kubernetes ist eine API-Ressource, die Schlüssel-Wert-Paare von Konfigurationsdaten speichert. Diese Daten können dann von Pods als Umgebungsvariablen, Befehlszeilenargumente oder Dateien verwendet werden.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-configmap
data:
  DATABASE_URL: "mysql://username:password@hostname:port/database"
  API_KEY: "123456789"
```

In diesem Beispiel wird eine ConfigMap mit den Schlüssel-Wert-Paaren für eine Datenbank-URL und eine API-Schlüssel erstellt.

### Verwendung von ConfigMaps in Pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
    - name: example-container
      image: nginx
      env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: example-configmap
              key: DATABASE_URL
```

Hier wird gezeigt, wie eine ConfigMap in einem Pod als Umgebungsvariable verwendet wird.

### Secrets
Secrets in Kubernetes sind API-Ressourcen, die sensible Daten wie Passwörter, Schlüssel und Zertifikate speichern. Sie werden base64-codiert im Cluster gespeichert.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: example-secret
type: Opaque
data:
  username: dXNlcm5hbWU=
  password: cGFzc3dvcmQ=
```

In diesem Beispiel wird ein Secret mit Benutzername und Passwort erstellt.

### Verwendung von Secrets in Pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
    - name: example-container
      image: nginx
      env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: example-secret
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: example-secret
              key: password
```