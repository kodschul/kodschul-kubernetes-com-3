# Lab 10.3 – Lösung: Pod Security

Fertiger Stand: [`project/examples/m10-security/l03-pod-security/`](../../project/examples/m10-security/l03-pod-security/)

## Aufgabe 1: `restricted` erzwingen und Ablehnung lesen

```bash
kubectl label namespace hello-prod pod-security.kubernetes.io/enforce=restricted
```

```text
Warning: existing pods in namespace "hello-prod" violate the new PodSecurity enforce level "restricted:latest"
Warning: hello-backend-6f7d8c9b5d-4hx2m (and 2 other pods): allowPrivilegeEscalation != false, unrestricted capabilities, runAsNonRoot != true, seccompProfile
Warning: hello-frontend-5c8d7b6f9d-2lmqp (and 2 other pods): allowPrivilegeEscalation != false, unrestricted capabilities, runAsNonRoot != true, seccompProfile
namespace/hello-prod labeled
```

```bash
kubectl rollout restart deployment/hello-frontend -n hello-prod
kubectl get rs,pods -n hello-prod
kubectl get events -n hello-prod --field-selector reason=FailedCreate
```

```text
deployment.apps/hello-frontend restarted

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-backend-6f7d8c9b5d    3         3         3       55m
replicaset.apps/hello-frontend-5c8d7b6f9d   3         3         3       47m
replicaset.apps/hello-frontend-7d4b9c8f6c   1         0         0       10s

NAME                                  READY   STATUS    RESTARTS   AGE
pod/hello-backend-6f7d8c9b5d-4hx2m    1/1     Running   0          55m
...
pod/hello-frontend-5c8d7b6f9d-2lmqp   1/1     Running   0          47m
...

LAST SEEN   TYPE      REASON         OBJECT                                     MESSAGE
4s          Warning   FailedCreate   replicaset/hello-frontend-7d4b9c8f6c       Error creating: pods "hello-frontend-7d4b9c8f6c-q9z2k" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "frontend" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "frontend" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "frontend" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "frontend" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

Die Meldung nennt jede fehlende Einstellung mit Feldname: das ist die Arbeitsliste für Aufgabe 3. Die alten Pods laufen weiter, weil nur neue Pods geprüft werden.

## Aufgabe 2: Images ohne root

```bash
cp examples/m10-security/l03-pod-security/backend/Dockerfile playground/backend/Dockerfile.nonroot
cp examples/m10-security/l03-pod-security/frontend/Dockerfile playground/frontend/Dockerfile.nonroot
cp examples/m10-security/l03-pod-security/frontend/Dockerfile.v2 playground/frontend/Dockerfile.v2-nonroot
diff playground/frontend/Dockerfile playground/frontend/Dockerfile.nonroot
```

```text
10a11,14
> # Eigener Benutzer ohne root-Rechte (UID 10001) und ein Datenordner, der ihm gehört
> RUN adduser -D -u 10001 hello && mkdir -p /data && chown 10001 /data
> USER 10001
> 
14c18
<     PORT=80
---
>     PORT=8080
16c20,21
< EXPOSE 80
---
> # Ports unter 1024 brauchen root-Rechte, deshalb 8080
> EXPOSE 8080
```

Ausgabe beim Vergleich mit dem Beispiel-Dockerfile aus Lab 1.3; bei eigenen Kommentaren weichen die Zeilennummern ab; entscheidend sind `adduser`/`USER 10001` und `PORT=8080`/`EXPOSE 8080`.

```bash
docker build -t hello-backend:v1-nonroot  -f playground/backend/Dockerfile.nonroot     playground/backend
docker build -t hello-frontend:v1-nonroot -f playground/frontend/Dockerfile.nonroot    playground/frontend
docker build -t hello-frontend:v2-nonroot -f playground/frontend/Dockerfile.v2-nonroot playground/frontend
docker images --filter "reference=hello-*"
docker run --rm hello-backend:v1-nonroot id
```

```text
REPOSITORY       TAG          IMAGE ID       CREATED          SIZE
hello-frontend   v2-nonroot   4c1e9a7b2d10   5 seconds ago    74.2MB
hello-frontend   v1-nonroot   9b8f6d3e1a22   12 seconds ago   74.2MB
hello-backend    v1-nonroot   2d7a5c9e8f31   20 seconds ago   63.9MB
hello-frontend   v2           ...
...
uid=10001(hello) gid=10001(hello) groups=10001(hello)
```

## Aufgabe 3: Chart erweitern

`playground/hello/Chart.yaml`:

```yaml
version: 0.3.0                 # Lab 10.3: securityContext und Port als Werte
```

`playground/hello/templates/frontend-deployment.yaml` (Backend genauso):

```yaml
    spec:
      automountServiceAccountToken: false
      securityContext:                         # Pod-Ebene
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: frontend
          image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.frontend.image.pullPolicy }}
          securityContext:                     # Container-Ebene
            {{- toYaml .Values.securityContext | nindent 12 }}
          env:
            - name: PORT
              value: {{ .Values.containerPort | quote }}
          ports:
            - name: http
              containerPort: {{ .Values.containerPort }}
```

`playground/values-prod.yaml`:

```yaml
host: prod.hello.localhost
color: lightblue
frontend:
  replicas: 3
  image:
    tag: v1-nonroot
backend:
  replicas: 3
  image:
    tag: v1-nonroot

containerPort: 8080

podSecurityContext:
  fsGroup: 10001

securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
  readOnlyRootFilesystem: true
```

```bash
helm lint playground/hello -f playground/values-prod.yaml
helm template hello playground/hello -f playground/values-prod.yaml | grep -B2 -A14 "securityContext:"
```

```text
==> Linting playground/hello
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

    spec:
      automountServiceAccountToken: false
      securityContext:                         # Pod-Ebene
        fsGroup: 10001
      containers:
        - name: backend
          image: "hello-backend:v1-nonroot"
          imagePullPolicy: Never
          securityContext:                     # Container-Ebene
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 10001
            seccompProfile:
              type: RuntimeDefault
          env:
            - name: PORT
              value: "8080"
          ports:
            - name: http
              containerPort: 8080
...
```

Ohne `-f values-prod.yaml` rendert das Chart `securityContext: {}` und Port 80: dev und `hello` laufen unverändert mit den root-Images weiter. `toYaml` sortiert die Schlüssel alphabetisch.

## Aufgabe 4: prod neu installieren

```bash
helm uninstall hello -n hello-prod --wait
kubectl get pvc -n hello-prod
helm install hello playground/hello -n hello-prod -f playground/values-prod.yaml --wait --timeout 2m
kubectl get pods -n hello-prod
```

```text
release "hello" uninstalled
No resources found in hello-prod namespace.

NAME: hello
NAMESPACE: hello-prod
STATUS: deployed
REVISION: 1
...
NAME                              READY   STATUS    RESTARTS   AGE
hello-backend-7c9d8b6f5d-6tq2x    1/1     Running   0          40s
hello-backend-7c9d8b6f5d-b8n4k    1/1     Running   0          40s
hello-backend-7c9d8b6f5d-kx7wd    1/1     Running   0          40s
hello-frontend-6b8f7d9c4d-2rj5m   1/1     Running   0          40s
hello-frontend-6b8f7d9c4d-hn9tz   1/1     Running   0          40s
hello-frontend-6b8f7d9c4d-w4cxq   1/1     Running   0          40s
```

Warum neu installieren statt `helm upgrade`: Das alte `access.log` auf der PVC wurde von root-Pods angelegt; ein Prozess mit UID 10001 dürfte nicht anhängen. Mit dem Release wird auch die PVC gelöscht, die neue entsteht leer. Die Historie aus Lab 9.3 geht dabei verloren; in echten Umgebungen passt man stattdessen einmalig die Dateirechte auf dem Volume an. `http://prod.hello.localhost` zeigt „Hello-App v1" auf blauem Grund mit Backend-Antwort und „Passwort gesetzt".

## Aufgabe 5: Härtung prüfen

```bash
kubectl exec deploy/hello-frontend -n hello-prod -- id
kubectl exec deploy/hello-frontend -n hello-prod -- tail -n 3 /data/access.log
kubectl exec deploy/hello-frontend -n hello-prod -- touch /app/test
```

```text
uid=10001(hello) gid=10001(hello) groups=10001(hello)
2026-11-17T13:22:05 hello-frontend-6b8f7d9c4d-hn9tz 10.1.0.212 v1
2026-11-17T13:22:09 hello-frontend-6b8f7d9c4d-2rj5m 10.1.0.210 v1
touch: /app/test: Read-only file system
command terminated with exit code 1
```

Das Frontend schreibt als UID 10001 auf die PVC unter `/data`; das Image selbst ist schreibgeschützt. `kubectl exec deploy/…` wählt einen der Pods; die Zeilen stammen von mehreren Pods, weil alle dieselbe PVC nutzen (Lab 7.2).

## Erweiterung: Pod-Security-Warnungen in hello-dev

```bash
kubectl label namespace hello-dev pod-security.kubernetes.io/warn=restricted
helm upgrade hello playground/hello -n hello-dev -f playground/values-dev.yaml
```

```text
namespace/hello-dev labeled
W1117 13:30:12.104221   48213 warnings.go:70] would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "backend" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (...), runAsNonRoot != true (...), seccompProfile (...)
W1117 13:30:12.118940   48213 warnings.go:70] would violate PodSecurity "restricted:latest": ... (container "frontend" ...)
Release "hello" has been upgraded. Happy Helming!
```

`warn` prüft auch Deployments und meldet „would violate"; die Pods starten trotzdem. So lässt sich vor dem Umstellen auf `enforce` sehen, was brechen würde. Die Form der Warnzeilen hängt von der Helm-Version ab.
