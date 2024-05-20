## Kubernetes: Secrets bereitstellen

Kubernetes Secrets ermöglichen es, vertrauliche Informationen wie Passwörter, Tokens und Schlüssel sicher in einem Cluster zu speichern und zu verwalten. Diese Secrets können dann Pods zur Verfügung gestellt werden, ohne dass sie im Quellcode oder in Konfigurationsdateien erscheinen. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Bereitstellung von Secrets in Kubernetes:

### Beispiel 1: Erstellen eines Secrets

Zuerst erstellen wir ein Secret mit einem Basis-64-codierten Benutzernamen und Passwort.

```sh
kubectl create secret generic mysecret --from-literal=username=myuser --from-literal=password=mypassword
```

Dieses Kommando erstellt ein Secret mit dem Namen mysecret, das die Basis-64-codierten Werte für username und password enthält.

### Beispiel 2: Bereitstellen eines Secrets als Umgebungsvariable
Ein Secret kann als Umgebungsvariable in einem Pod verwendet werden.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-example
spec:
  containers:
  - name: myapp-container
    image: myapp:1.0
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: password
```

In diesem Beispiel wird das Secret mysecret verwendet, um die Umgebungsvariablen USERNAME und PASSWORD in den Container zu injecten.

### Beispiel 3: Bereitstellen eines Secrets als Volume
Ein Secret kann auch als Volume in einem Pod gemountet werden.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-example
spec:
  containers:
  - name: myapp-container
    image: myapp:1.0
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secret-volume
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: mysecret
```

In diesem Beispiel wird das Secret mysecret in den Pfad /etc/secret-volume des Containers gemountet. Die Dateien im Secret werden als Dateien im gemounteten Verzeichnis erscheinen.

### Beispiel 4: Erstellen eines Secrets aus einer Datei
Ein Secret kann auch aus einer Datei erstellt werden.

```sh
echo -n 'myuser' > ./username.txt
echo -n 'mypassword' > ./password.txt
kubectl create secret generic myfile-secret --from-file=./username.txt --from-file=./password.txt
```

Dieses Kommando erstellt ein Secret mit dem Namen myfile-secret aus den Dateien username.txt und password.txt.

### Beispiel 5: Deklaratives Erstellen eines Secrets
Secrets können auch deklarativ in YAML erstellt werden.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: bXl1c2Vy
  password: bXlwYXNzd29yZA==
```

In diesem Beispiel wird ein Secret namens mysecret erstellt, wobei username und password Base64-codierte Werte enthalten.