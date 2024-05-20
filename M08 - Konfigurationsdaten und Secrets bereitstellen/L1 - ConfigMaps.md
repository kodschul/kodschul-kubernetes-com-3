## Kubernetes: ConfigMaps bereitstellen

ConfigMaps in Kubernetes ermöglichen es, Konfigurationsdaten von Container-Images zu trennen und Konfigurationswerte in einer zentralen und leicht zugänglichen Art und Weise zu verwalten. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in das Bereitstellen von ConfigMaps:

### Erstellen eines ConfigMaps

#### Beispiel 1: Erstellen eines ConfigMaps aus einer Datei

```bash
kubectl create configmap my-config --from-file=my-config-file.txt
```

Dieser Befehl erstellt einen ConfigMap mit dem Namen my-config aus einer Datei my-config-file.txt. Der Inhalt der Datei wird als Schlüssel-Wert-Paare in den ConfigMap gespeichert.

#### Beispiel 2: Erstellen eines ConfigMaps aus Literal-Werten

```bash
kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2
```

Dieser Befehl erstellt einen ConfigMap mit dem Namen my-config und fügt die angegebenen Schlüssel-Wert-Paare hinzu.

### Verwenden eines ConfigMaps
#### Beispiel 3: ConfigMap als Umgebungsvariable in einem Pod verwenden

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-env-example
spec:
  containers:
  - name: myapp-container
    image: myapp:1.0
    env:
    - name: CONFIG_KEY1
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: key1

```

In diesem Beispiel wird der Wert key1 aus dem my-config ConfigMap als Umgebungsvariable CONFIG_KEY1 im Container verwendet.

#### Beispiel 4: ConfigMap als Datei in einem Volume mounten

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume-example
spec:
  containers:
  - name: myapp-container
    image: myapp:1.0
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: my-config

```

In diesem Beispiel wird der gesamte my-config ConfigMap als Volume gemountet und im Verzeichnis /etc/config im Container bereitgestellt. Jeder Schlüssel im ConfigMap wird zu einer Datei im gemounteten Verzeichnis, und der Wert des Schlüssels wird zum Inhalt der Datei.

#### Beispiel 5: Verwenden eines ConfigMaps in einem Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: configmap-deployment-example
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp-container
        image: myapp:1.0
        envFrom:
        - configMapRef:
            name: my-config
```

In diesem Beispiel wird der my-config ConfigMap in einem Deployment verwendet, um Umgebungsvariablen für alle Container in den Pods des Deployments bereitzustellen.