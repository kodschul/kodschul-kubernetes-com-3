# Lab 9.2 – Lösung: Eigenes Chart für die Hello-App

Fertiges Chart: [`project/examples/m09-helm/l02-own-chart/hello/`](../../project/examples/m09-helm/l02-own-chart/hello/)

## Aufgabe 1: Starter kopieren und rendern

```bash
cp -R starters/m09-l02-hello playground/hello
ls -R playground/hello
helm lint playground/hello
```

```text
playground/hello:
Chart.yaml	templates	values.yaml

playground/hello/templates:
NOTES.txt		backend-service.yaml	frontend-deployment.yaml	httproute.yaml
_helpers.tpl		configmap.yaml		frontend-service.yaml	pvc.yaml
backend-deployment.yaml

==> Linting playground/hello
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

Der Starter rendert bereits fehlerfrei; die festen Werte (`replicas: 2`, `hello-frontend:v2`, `lightyellow`, `hello.localhost`) stehen aber noch im Template statt in `values.yaml`.

## Aufgabe 2: Werte und Platzhalter

Ergänzung in `values.yaml`:

```yaml
# Hintergrundfarbe der Seite (landet in der ConfigMap, Lab 6.1)
color: lightyellow

# Hostname der HTTPRoute (Lab 5.3)
host: hello.localhost
```

`templates/backend-deployment.yaml`:

```yaml
spec:
  replicas: {{ .Values.backend.replicas }}
  ...
      labels:
        ...
        version: {{ .Values.backend.image.tag | quote }}
  ...
          image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"
```

`templates/frontend-deployment.yaml`:

```yaml
spec:
  replicas: {{ .Values.frontend.replicas }}
  ...
        version: {{ .Values.frontend.image.tag | default .Chart.AppVersion | quote }}
  ...
          # leerer Tag in values.yaml -> appVersion aus Chart.yaml
          image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag | default .Chart.AppVersion }}"
```

`templates/configmap.yaml`:

```yaml
data:
  BACKEND_URL: "http://{{ .Release.Name }}-backend"
  APP_COLOR: {{ .Values.color | quote }}
```

`templates/httproute.yaml`:

```yaml
  hostnames:
    - {{ .Values.host | quote }}
```

Warum `default .Chart.AppVersion`: Der Tag des Frontends folgt so der App-Version des Charts; wer einen anderen Tag braucht, setzt `frontend.image.tag`.

## Aufgabe 3: Prüfen

```bash
helm lint playground/hello
helm template hello playground/hello -n hello --set color=pink --set frontend.image.tag=v1 \
  | grep -E "image:|replicas:|APP_COLOR|localhost"
```

```text
==> Linting playground/hello
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

  APP_COLOR: "pink"
  replicas: 2
          image: "hello-backend:v1"
  replicas: 2
          image: "hello-frontend:v1"
    - "hello.localhost"
```

Ohne `--set` steht dort `APP_COLOR: "lightyellow"` und `image: "hello-frontend:v2"`.

## Aufgabe 4: Alte Objekte löschen

```bash
kubectl delete -n hello deployment/backend deployment/frontend service/backend service/frontend \
  configmap/hello-config pvc/hello-data cronjob/hello-backup hpa/frontend httproute/hello \
  --ignore-not-found
kubectl delete pod load -n hello --ignore-not-found
kubectl get all,configmap,pvc,httproute -n hello
kubectl get secret hello-secret -n hello
```

```text
deployment.apps "backend" deleted
deployment.apps "frontend" deleted
service "backend" deleted
service "frontend" deleted
configmap "hello-config" deleted
persistentvolumeclaim "hello-data" deleted
cronjob.batch "hello-backup" deleted
horizontalpodautoscaler.autoscaling "frontend" deleted
httproute.gateway.networking.k8s.io "hello" deleted

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      1d

NAME           TYPE     DATA   AGE
hello-secret   Opaque   1      1d
```

`kube-root-ca.crt` legt Kubernetes in jedem Namespace selbst an. Pods, die gerade beendet werden, können noch kurz als `Terminating` erscheinen.

## Aufgabe 5: Installieren

```bash
helm install hello playground/hello -n hello --dry-run=server | tail -15
helm install hello playground/hello -n hello
helm list -n hello
kubectl get pods,svc,httproute -n hello
```

```text
NAME: hello
LAST DEPLOYED: Tue Nov 17 11:31:05 2026
NAMESPACE: hello
STATUS: deployed
REVISION: 1
NOTES:
Hello-App installiert: Release "hello" im Namespace "hello" (Chart hello-0.1.0).

Über das Gateway:
  http://hello.localhost
  http://hello.localhost/api

Ohne Gateway:
  kubectl port-forward -n hello svc/hello-frontend 8080:80
  danach http://localhost:8080

NAME   NAMESPACE  REVISION  UPDATED                            STATUS    CHART        APP VERSION
hello  hello      1         2026-11-17 11:31:05.88 +0100 CET   deployed  hello-0.1.0  v2

NAME                                  READY   STATUS    RESTARTS   AGE
pod/hello-backend-5d7f9c6b8d-4kq2w    1/1     Running   0          25s
pod/hello-backend-5d7f9c6b8d-r8m5t    1/1     Running   0          25s
pod/hello-frontend-6c9b7d5f4b-hx2lp   1/1     Running   0          25s
pod/hello-frontend-6c9b7d5f4b-zt7vn   1/1     Running   0          25s

NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/hello-backend    ClusterIP   10.105.33.18    <none>        80/TCP    25s
service/hello-frontend   ClusterIP   10.98.211.140   <none>        80/TCP    25s

NAME                                        HOSTNAMES             AGE
httproute.gateway.networking.k8s.io/hello   ["hello.localhost"]   25s
```

Beim Probelauf mit `--dry-run=server` steht `STATUS: pending-install`, und `kubectl get pods` bleibt leer. `http://hello.localhost` zeigt „Hello-App v2" auf hellgelbem Grund, den Backend-Pod und „Passwort gesetzt"; `http://hello.localhost/api` liefert JSON mit `"version": "v1"`.

## Erweiterung: HPA im Chart

`templates/hpa.yaml`:

```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Release.Name }}-frontend
  labels:
    {{- include "hello.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ .Release.Name }}-frontend
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
{{- end }}
```

In `values.yaml`:

```yaml
autoscaling:
  enabled: false
```

`helm template hello playground/hello --set autoscaling.enabled=true | grep -A3 "kind: HorizontalPodAutoscaler"` zeigt den HPA; ohne den Schalter fehlt er. Mit aktivem HPA legt der HPA die Anzahl Kopien fest, nicht `frontend.replicas`.
