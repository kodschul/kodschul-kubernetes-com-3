# Lab 6.1 – Lösung: ConfigMaps

Alle Befehle im Ordner `project/`. Pod-Namen und Zeiten weichen ab.

## Aufgabe 1: ConfigMap anlegen

```bash
cp starters/m06-l01-configmap.yaml playground/k8s/configmap.yaml
```

```yaml
# playground/k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-config
  labels:
    app: hello
data:
  BACKEND_URL: http://backend
  APP_COLOR: lightyellow
```

```bash
kubectl apply -f playground/k8s/configmap.yaml
kubectl describe configmap hello-config
```

```text
configmap/hello-config created

Name:         hello-config
Namespace:    hello
Labels:       app=hello
Annotations:  <none>

Data
====
APP_COLOR:
----
lightyellow

BACKEND_URL:
----
http://backend


BinaryData
====

Events:  <none>
```

## Aufgabe 2: Frontend mit envFrom

```bash
cp starters/m06-l01-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
```

Ergänzter Ausschnitt (der `env`-Block mit `BACKEND_URL` ist entfallen):

```yaml
      containers:
        - name: frontend
          image: hello-frontend:v2
          imagePullPolicy: Never
          ports:
            - containerPort: 80
          envFrom:
            - configMapRef:
                name: hello-config
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
```

```text
deployment.apps/frontend configured
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "frontend" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "frontend" rollout to finish: 1 old replicas are pending termination...
deployment "frontend" successfully rolled out
```

Das Pod-Template hat sich geändert, deshalb rollt `apply` neue Pods aus. `http://hello.localhost` ist jetzt hellgelb, Titel weiter „Hello-App v2": Die Farbe aus der ConfigMap überschreibt `APP_COLOR=lightgreen` aus dem Image, die Version kommt weiter aus dem Image.

## Aufgabe 3: Umgebungsvariablen im Pod

```bash
kubectl exec deploy/frontend -- env | grep -E '^(APP_|BACKEND_URL)'
```

```text
BACKEND_URL=http://backend
APP_COLOR=lightyellow
APP_VERSION=v2
```

`APP_VERSION` stammt aus dem Dockerfile, die anderen beiden aus der ConfigMap. Ohne den Filter zeigt `env` zusätzlich Variablen wie `BACKEND_SERVICE_HOST`: Kubernetes setzt sie für jeden Service, der beim Pod-Start existiert; der DNS-Name `backend` ist der übliche Weg.

## Aufgabe 4: ConfigMap ändern ohne Neustart

```yaml
data:
  BACKEND_URL: http://backend
  APP_COLOR: lightpink
```

```bash
kubectl apply -f playground/k8s/configmap.yaml
kubectl exec deploy/frontend -- env | grep -E '^(APP_|BACKEND_URL)'
```

```text
configmap/hello-config configured

BACKEND_URL=http://backend
APP_COLOR=lightyellow
APP_VERSION=v2
```

Die Seite bleibt gelb. Umgebungsvariablen werden nur beim Start eines Containers gesetzt.

## Aufgabe 5: rollout restart

```bash
kubectl rollout restart deployment/frontend
kubectl rollout status deployment/frontend
kubectl get pods -l tier=frontend
```

```text
deployment.apps/frontend restarted
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
…
deployment "frontend" successfully rolled out

NAME                        READY   STATUS    RESTARTS   AGE
frontend-7b8f6d5c9c-5mzqp   1/1     Running   0          14s
frontend-7b8f6d5c9c-hd2wx   1/1     Running   0          10s
frontend-7b8f6d5c9c-t9r4k   1/1     Running   0          6s
```

Die Seite ist rosa. `rollout restart` setzt im Pod-Template die Annotation `kubectl.kubernetes.io/restartedAt`; dadurch entsteht ein neuer Rollout wie in Lab 4.3, ohne Ausfall.

## Erweiterung: ConfigMap als Datei

```yaml
# playground/k8s/configmap-files.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-files
data:
  config.json: |
    { "color": "lightyellow", "features": { "darkMode": false } }
```

Ergänzung im Frontend-Deployment (unter dem Container und auf Höhe von `containers`):

```yaml
          volumeMounts:
            - name: config
              mountPath: /etc/hello-config
              readOnly: true
      volumes:
        - name: config
          configMap:
            name: hello-files
```

```bash
kubectl apply -f playground/k8s/configmap-files.yaml
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
kubectl exec deploy/frontend -- cat /etc/hello-config/config.json
```

```text
{ "color": "lightyellow", "features": { "darkMode": false } }
```

Nach einer Änderung von `darkMode` auf `true` und `kubectl apply -f playground/k8s/configmap-files.yaml` zeigt derselbe `cat`-Befehl nach etwa einer Minute den neuen Inhalt, ohne dass die Pods neu starten. Die Hello-App liest diese Datei nicht; die Erweiterung zeigt nur den Mechanismus.
