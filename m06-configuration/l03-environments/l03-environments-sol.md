# Lab 6.3 – Lösung: Namespaces für Umgebungen

Alle Befehle im Ordner `project/`. Pod-Namen und IPs weichen ab.

## Aufgabe 1: Namespaces anlegen

```bash
cp starters/m06-l03-namespaces.yaml playground/k8s/namespaces.yaml
```

```yaml
# playground/k8s/namespaces.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello-dev
  labels:
    app: hello
    environment: dev
---
apiVersion: v1
kind: Namespace
metadata:
  name: hello-prod
  labels:
    app: hello
    environment: prod
```

```bash
kubectl apply -f playground/k8s/namespaces.yaml
kubectl get namespaces -l app=hello
```

```text
namespace/hello-dev created
namespace/hello-prod created

NAME         STATUS   AGE
hello-dev    Active   3s
hello-prod   Active   3s
```

Der Namespace `hello` aus Lab 2.4 trägt kein Label `app: hello` und erscheint deshalb nicht.

## Aufgabe 2: ConfigMap je Umgebung

```bash
mkdir -p playground/k8s/dev playground/k8s/prod
cp starters/m06-l03-configmap.yaml playground/k8s/dev/configmap.yaml
cp starters/m06-l03-configmap.yaml playground/k8s/prod/configmap.yaml
```

```yaml
# playground/k8s/dev/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-config
  labels:
    app: hello
data:
  BACKEND_URL: http://backend
  APP_COLOR: lightgreen
```

```yaml
# playground/k8s/prod/configmap.yaml (nur APP_COLOR anders)
data:
  BACKEND_URL: http://backend
  APP_COLOR: lightblue
```

Beide Dateien nutzen denselben Namen `hello-config`, damit das geteilte Frontend-Deployment in jeder Umgebung unverändert passt.

## Aufgabe 3: Secret je Umgebung

```bash
kubectl create secret generic hello-secret --from-literal=admin-password=uebung-2026 -n hello-dev
kubectl create secret generic hello-secret --from-literal=admin-password=uebung-2026 -n hello-prod
```

```text
secret/hello-secret created
secret/hello-secret created
```

Im Alltag hat jede Umgebung ein eigenes Passwort; der gleiche Übungswert hält die Übung kurz.

## Aufgabe 4: Geteilte Manifeste je Namespace anwenden

```bash
kubectl apply -n hello-dev -f playground/k8s/dev/ \
  -f playground/k8s/backend-deployment.yaml -f playground/k8s/backend-service.yaml \
  -f playground/k8s/frontend-deployment.yaml -f playground/k8s/frontend-service.yaml

kubectl apply -n hello-prod -f playground/k8s/prod/ \
  -f playground/k8s/backend-deployment.yaml -f playground/k8s/backend-service.yaml \
  -f playground/k8s/frontend-deployment.yaml -f playground/k8s/frontend-service.yaml

kubectl get deployments -A -l app=hello
```

```text
configmap/hello-config created
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created
configmap/hello-config created
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created

NAMESPACE    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
hello        backend    3/3     3            3           3h
hello        frontend   3/3     3            3           25m
hello-dev    backend    3/3     3            3           40s
hello-dev    frontend   3/3     3            3           40s
hello-prod   backend    3/3     3            3           20s
hello-prod   frontend   3/3     3            3           20s
```

Die ConfigMap wird zuerst angewendet (erstes `-f`); so starten die Frontend-Pods gleich mit der richtigen Farbe.

## Aufgabe 5: Beide Umgebungen prüfen und DNS über Namespaces

```bash
kubectl port-forward -n hello-dev svc/frontend 8081:80     # Terminal 2
kubectl port-forward -n hello-prod svc/frontend 8082:80    # Terminal 3
```

| Adresse | Farbe | Inhalt |
| --- | --- | --- |
| `http://localhost:8081` | hellgrün | „Hello-App v2", Backend-Pod aus `hello-dev`, `Passwort gesetzt` |
| `http://localhost:8082` | hellblau | „Hello-App v2", Backend-Pod aus `hello-prod`, `Passwort gesetzt` |
| `http://hello.localhost` | Farbe aus Lab 6.1 | unverändert, Namespace `hello` |

```bash
kubectl run tmp -n hello-dev --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- http://backend.hello-prod.svc.cluster.local
kubectl get pods -n hello-prod -l tier=backend
```

```text
{"ip":"10.1.0.71","pod":"backend-5d7c9f6b8b-q8w2n","time":"15:21:44","version":"v1"}
pod "tmp" deleted

NAME                       READY   STATUS    RESTARTS   AGE
backend-5d7c9f6b8b-l4fxs   1/1     Running   0          3m
backend-5d7c9f6b8b-q8w2n   1/1     Running   0          3m
backend-5d7c9f6b8b-vz6tc   1/1     Running   0          3m
```

Der Pod in `hello-dev` erreicht das Backend in `hello-prod`: Namespaces trennen Namen, nicht das Netzwerk.

## Erweiterung: ResourceQuota

```yaml
# playground/k8s/resourcequota-dev.yaml (außerhalb von dev/, damit sie nicht mit der ConfigMap angewendet wird)
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-limits
spec:
  hard:
    pods: "10"
    services: "5"
    configmaps: "10"
    secrets: "10"
```

```bash
kubectl apply -n hello-dev -f playground/k8s/resourcequota-dev.yaml
kubectl scale deployment frontend -n hello-dev --replicas=8
kubectl describe resourcequota dev-limits -n hello-dev
kubectl get events -n hello-dev --field-selector reason=FailedCreate
```

```text
resourcequota/dev-limits created
deployment.apps/frontend scaled

Name:       dev-limits
Namespace:  hello-dev
Resource    Used  Hard
--------    ----  ----
configmaps  2     10
pods        10    10
secrets     1     10
services    2     5

LAST SEEN   TYPE      REASON         OBJECT                          MESSAGE
5s          Warning   FailedCreate   replicaset/frontend-5f7d9c8b4d   Error creating: pods "frontend-5f7d9c8b4d-xxxxx" is forbidden: exceeded quota: dev-limits, requested: pods=1, used: pods=10, limited: pods=10
```

Statt 8 laufen nur 7 Frontend-Pods (3 Backend + 7 Frontend = 10). Aufräumen:

```bash
kubectl scale deployment frontend -n hello-dev --replicas=3
kubectl delete resourcequota dev-limits -n hello-dev
```
