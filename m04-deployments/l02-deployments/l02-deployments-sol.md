# Lab 4.2 – Lösung: Deployments

Alle Befehle laufen im Ordner `project/`. Hash-Werte in Namen, IPs und Zeiten weichen im eigenen Cluster ab.

## Aufgabe 1: Einzelobjekte abräumen

```bash
kubectl delete rs frontend
kubectl delete pod backend
rm playground/k8s/frontend-replicaset.yaml playground/k8s/backend-pod.yaml
```

```text
replicaset.apps "frontend" deleted
pod "backend" deleted
```

Das Löschen des ReplicaSets löscht auch seine drei Pods.

## Aufgabe 2: Backend aus der Vorlage

```bash
kubectl create deployment backend --image=hello-backend:v1 --port=80 --dry-run=client -o yaml > playground/k8s/backend-deployment.yaml
```

Angepasste Datei `playground/k8s/backend-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: hello
    tier: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello
      tier: backend
  template:
    metadata:
      labels:
        app: hello
        tier: backend
        version: v1
    spec:
      containers:
        - name: backend
          image: hello-backend:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

```bash
kubectl apply -f playground/k8s/backend-deployment.yaml
```

```text
deployment.apps/backend created
```

## Aufgabe 3: Frontend aus dem Starter

```bash
cp starters/m04-l02-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
```

Ergänzte Zeilen:

```yaml
kind: Deployment
...
          env:
            - name: BACKEND_URL
              value: "http://backend"
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl get deploy,rs,pods
```

```text
deployment.apps/frontend created
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    1/1     1            1           40s
deployment.apps/frontend   1/1     1            1           5s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-6c8d9f7b5d    1         1         1       40s
replicaset.apps/frontend-7d9c5b8f6b   1         1         1       5s

NAME                            READY   STATUS    RESTARTS   AGE
pod/backend-6c8d9f7b5d-4tq9w    1/1     Running   0          40s
pod/frontend-7d9c5b8f6b-x2kqp   1/1     Running   0          5s
```

## Aufgabe 4: skalieren und Datei nachziehen

```bash
kubectl scale deployment/backend deployment/frontend --replicas=3
kubectl get deploy
```

```text
deployment.apps/backend scaled
deployment.apps/frontend scaled
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
backend    3/3     3            3           2m
frontend   3/3     3            3           1m
```

In beiden Dateien `replicas: 3` eintragen, dann:

```bash
kubectl apply -f playground/k8s/
kubectl get deploy
```

```text
deployment.apps/backend configured
deployment.apps/frontend configured
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
backend    3/3     3            3           3m
frontend   3/3     3            3           2m
```

Ohne die Änderung in den Dateien würde `apply` beide Deployments auf einen Pod zurücksetzen. Weiter liegen nur die beiden Deployment-Dateien in `playground/k8s/`; die Dateien aus Lab 3.x und 4.1 wurden in Aufgabe 1 gelöscht.

## Aufgabe 5: Self-Healing und Seite

```bash
kubectl delete pod frontend-7d9c5b8f6b-x2kqp      # eigenen Namen einsetzen
kubectl get pods -l tier=frontend
kubectl port-forward deployment/frontend 8080:80  # zweites Terminal
```

```text
pod "frontend-7d9c5b8f6b-x2kqp" deleted
NAME                        READY   STATUS    RESTARTS   AGE
frontend-7d9c5b8f6b-m8vtl   1/1     Running   0          2m
frontend-7d9c5b8f6b-q4zrn   1/1     Running   0          2m
frontend-7d9c5b8f6b-z7hcd   1/1     Running   0          3s
Forwarding from 127.0.0.1:8080 -> 80
```

`port-forward deployment/frontend` wählt einen der Pods aus. Die Seite zeigt:

```text
Hello-App v1
Frontend-Pod: frontend-7d9c5b8f6b-m8vtl (10.1.0.41)
Backend: Backend nicht erreichbar (http://backend): ConnectionError
Admin: kein Passwort gesetzt
```

Der Name `backend` lässt sich noch nicht auflösen; der Service dazu folgt in Lab 5.1.
