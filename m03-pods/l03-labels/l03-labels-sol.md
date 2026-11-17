# Lab 3.3 – Lösung: Labels und Selektoren

Alle Befehle laufen im Ordner `project/`. Pod-Alter weichen im eigenen Cluster ab.

## Aufgabe 1: Labels und Annotation in den Dateien

`playground/k8s/backend-pod.yaml`:

```yaml
metadata:
  name: backend
  labels:
    app: hello
    tier: backend
    version: v1
  annotations:
    description: "JSON-API der Hello-App"
```

`playground/k8s/frontend-pod.yaml`:

```yaml
metadata:
  name: frontend
  labels:
    app: hello
    tier: frontend
    version: v1
  annotations:
    description: "Webseite der Hello-App, fragt das Backend"
```

```bash
kubectl apply -f playground/k8s/
```

```text
pod/backend configured
pod/frontend configured
```

Labels und Annotations dürfen sich an laufenden Pods ändern; die Pods laufen ohne Neustart weiter.

## Aufgabe 2: zweiter Frontend-Pod und Label-Ansicht

```bash
kubectl run frontend-v2 --image=hello-frontend:v2 --image-pull-policy=Never --labels=app=hello,tier=frontend,version=v2
kubectl get pods --show-labels
kubectl get pods -L tier,version
```

```text
pod/frontend-v2 created
NAME          READY   STATUS    RESTARTS   AGE   LABELS
backend       1/1     Running   0          40m   app=hello,tier=backend,version=v1
frontend      2/2     Running   0          15m   app=hello,tier=frontend,version=v1
frontend-v2   1/1     Running   0          5s    app=hello,tier=frontend,version=v2

NAME          READY   STATUS    RESTARTS   AGE   TIER       VERSION
backend       1/1     Running   0          40m   backend    v1
frontend      2/2     Running   0          15m   frontend   v1
frontend-v2   1/1     Running   0          8s    frontend   v2
```

`kubectl run` legt einen Pod imperativ an (Lab 2.4); für diesen Testpod reicht das.

## Aufgabe 3: filtern

```bash
kubectl get pods -l app=hello                    # alle drei
kubectl get pods -l tier=frontend                # frontend, frontend-v2
kubectl get pods -l tier=frontend,version=v1     # nur frontend
kubectl get pods -l 'version in (v1,v2)'         # alle drei
```

```text
NAME       READY   STATUS    RESTARTS   AGE
frontend   2/2     Running   0          16m
```

(Ausgabe der dritten Abfrage.) Das Komma verknüpft beide Bedingungen mit UND.

## Aufgabe 4: Labels nachträglich ändern

```bash
kubectl label pod frontend-v2 stage=test
kubectl label pod frontend-v2 stage=review --overwrite
kubectl annotate pod frontend-v2 description="Testpod für v2"
kubectl get pods -l stage=review
```

```text
pod/frontend-v2 labeled
pod/frontend-v2 labeled
pod/frontend-v2 annotated
NAME          READY   STATUS    RESTARTS   AGE
frontend-v2   1/1     Running   0          2m
```

Ohne `--overwrite` endet der zweite Befehl mit `error: 'stage' already has a value (test), and --overwrite is false`.

## Aufgabe 5: über Selektor löschen

```bash
kubectl delete pods -l stage=review
kubectl get pods -l tier=frontend,version=v1
kubectl get pods
```

```text
pod "frontend-v2" deleted
NAME       READY   STATUS    RESTARTS   AGE
frontend   2/2     Running   0          18m
NAME       READY   STATUS    RESTARTS   AGE
backend    1/1     Running   0          43m
frontend   2/2     Running   0          18m
```

Löschen per Selektor trifft alle passenden Pods. Vorher mit `kubectl get pods -l ...` prüfen, was getroffen wird.
