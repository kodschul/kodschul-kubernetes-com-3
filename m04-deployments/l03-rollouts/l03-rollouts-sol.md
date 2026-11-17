# Lab 4.3 – Lösung: Rollout und Rollback

Alle Befehle laufen im Ordner `project/`. Hash-Werte in Namen und Zeiten weichen im eigenen Cluster ab.

## Aufgabe 1: Strategie und change-cause

```bash
cp starters/m04-l03-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
```

Ergänzte Zeilen:

```yaml
metadata:
  name: frontend
  labels:
    app: hello
    tier: frontend
  annotations:
    kubernetes.io/change-cause: "Start mit v1"
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout history deployment/frontend
```

```text
deployment.apps/frontend configured
deployment.apps/frontend
REVISION  CHANGE-CAUSE
1         Start mit v1
```

Strategie und Annotation ändern das Template nicht: es startet kein Rollout, die Pods laufen weiter. Das Deployment überträgt den `change-cause` auf das aktuelle ReplicaSet (Revision 1).

## Aufgabe 2: Rollout auf v2

Geänderte Zeilen:

```yaml
  annotations:
    kubernetes.io/change-cause: "Update auf v2"
...
      labels:
        app: hello
        tier: frontend
        version: v2
...
          image: hello-frontend:v2
```

```bash
kubectl get pods -l tier=frontend -w                 # zweites Terminal
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
kubectl get rs
```

Watch-Terminal (gekürzt):

```text
frontend-5f6b8c4d7c-9vk2m   0/1     Pending             0          0s
frontend-5f6b8c4d7c-9vk2m   0/1     ContainerCreating   0          0s
frontend-5f6b8c4d7c-9vk2m   1/1     Running             0          1s
frontend-7d9c5b8f6b-m8vtl   1/1     Terminating         0          25m
frontend-5f6b8c4d7c-h7xqt   0/1     Pending             0          0s
frontend-5f6b8c4d7c-h7xqt   1/1     Running             0          1s
frontend-7d9c5b8f6b-q4zrn   1/1     Terminating         0          25m
frontend-5f6b8c4d7c-t4wpl   0/1     Pending             0          0s
frontend-5f6b8c4d7c-t4wpl   1/1     Running             0          1s
frontend-7d9c5b8f6b-z7hcd   1/1     Terminating         0          22m
```

```text
deployment.apps/frontend configured
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "frontend" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "frontend" rollout to finish: 1 old replicas are pending termination...
deployment "frontend" successfully rolled out
NAME                  DESIRED   CURRENT   READY   AGE
backend-6c8d9f7b5d    3         3         3       30m
frontend-5f6b8c4d7c   3         3         3       15s
frontend-7d9c5b8f6b   0         0         0       27m
```

Jeder neue Pod läuft, bevor ein alter endet (`maxUnavailable: 0`), und es sind nie mehr als vier Pods (`maxSurge: 1`).

## Aufgabe 3: Seite prüfen

```bash
kubectl port-forward deployment/frontend 8080:80     # zweites Terminal, Watch vorher mit Strg+C beenden
```

```text
Hello-App v2
Frontend-Pod: frontend-5f6b8c4d7c-9vk2m (10.1.0.47)
Backend: Backend nicht erreichbar (http://backend): ConnectionError
Admin: kein Passwort gesetzt
```

Hintergrund hellgrün: Version und Farbe stammen aus dem Image `v2` (Lab 1.3). Die Backend-Meldung ist bis Lab 5.1 erwartet.

## Aufgabe 4: kaputter Rollout auf v3

Geänderte Zeilen: `change-cause: "Update auf v3"`, `version: v3`, `image: hello-frontend:v3`.

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend --timeout=30s
kubectl get pods -l tier=frontend
kubectl describe pod frontend-6b7d9f5c8d-r2nzx      # Name des neuen Pods einsetzen
```

```text
deployment.apps/frontend configured
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
error: timed out waiting for the condition
NAME                        READY   STATUS              RESTARTS   AGE
frontend-5f6b8c4d7c-9vk2m   1/1     Running             0          6m
frontend-5f6b8c4d7c-h7xqt   1/1     Running             0          6m
frontend-5f6b8c4d7c-t4wpl   1/1     Running             0          6m
frontend-6b7d9f5c8d-r2nzx   0/1     ErrImageNeverPull   0          40s
...
Events:
  Warning  ErrImageNeverPull  10s (x4 over 40s)  kubelet  Container image "hello-frontend:v3" is not present with pull policy of Never
```

Der neue Pod wird nie bereit; wegen `maxUnavailable: 0` bleiben alle drei `v2`-Pods. Die Seite lädt weiter grün mit `v2` (Port-Forward ggf. neu starten).

## Aufgabe 5: Rollback und Datei angleichen

```bash
kubectl rollout undo deployment/frontend
kubectl rollout status deployment/frontend
kubectl rollout history deployment/frontend
```

```text
deployment.apps/frontend rolled back
deployment "frontend" successfully rolled out
deployment.apps/frontend
REVISION  CHANGE-CAUSE
1         Start mit v1
3         Update auf v3
4         Update auf v2
```

Revision 2 (`v2`) ist als Revision 4 zurückgekommen; der `v3`-Pod ist gelöscht. Datei zurücksetzen: `change-cause: "Update auf v2"`, `version: v2`, `image: hello-frontend:v2`. Danach:

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout history deployment/frontend
kubectl get deploy frontend
```

```text
deployment.apps/frontend configured
deployment.apps/frontend
REVISION  CHANGE-CAUSE
1         Start mit v1
3         Update auf v3
4         Update auf v2
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
frontend   3/3     3            3           35m
```

Keine neue Revision: das Template in der Datei entspricht dem laufenden Stand. `configured` statt `unchanged` kommt daher, dass `kubectl apply` seine eigene Notiz über den zuletzt angewendeten Stand aktualisiert.

## Erweiterung: Recreate

```yaml
  strategy:
    type: Recreate                   # rollingUpdate-Block entfernen, sonst lehnt die API ab
```

Mit Image `v1` angewendet zeigt das Watch-Terminal zuerst dreimal `Terminating`, danach drei neue Pods. In dieser Zeit antwortet kein Frontend-Pod. Anschließend die eigentliche Datei (`v2`, `RollingUpdate`) wieder anwenden.
