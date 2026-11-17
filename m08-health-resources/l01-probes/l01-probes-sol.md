# Lab 8.1 – Lösung: Liveness, Readiness und Startup Probes

Alle Befehle laufen im Ordner `project/`. Namen, Zeiten und IPs weichen ab.

## Aufgabe 1: Probes ergänzen

```bash
cp starters/m08-l01-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
cp starters/m08-l01-backend-deployment.yaml playground/k8s/backend-deployment.yaml
# TODOs ergänzen (siehe unten)
kubectl apply -f playground/k8s/frontend-deployment.yaml -f playground/k8s/backend-deployment.yaml
kubectl rollout status deployment/frontend
kubectl rollout status deployment/backend
kubectl describe deployment frontend | grep -E "Liveness|Readiness"
```

Im Container `frontend` und ebenso im Container `backend`:

```yaml
          readinessProbe:
            httpGet:
              path: /healthz
              port: 80
            periodSeconds: 5
            failureThreshold: 2
          livenessProbe:
            httpGet:
              path: /healthz
              port: 80
            periodSeconds: 10
            failureThreshold: 3
```

```text
deployment.apps/frontend configured
deployment.apps/backend configured
deployment "frontend" successfully rolled out
deployment "backend" successfully rolled out
    Liveness:     http-get http://:80/healthz delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:80/healthz delay=0s timeout=1s period=5s #success=1 #failure=2
```

Vollständige Dateien: [`examples/m08-health-resources/l01-probes/`](../../project/examples/m08-health-resources/l01-probes/)

## Aufgabe 2: Ausfall in einem Pod auslösen

```bash
# Terminal 2
kubectl get pods -l tier=frontend -w
# Terminal 1
kubectl get pods -l tier=frontend
kubectl exec frontend-8b6f5c7d9-4kq2m -- wget -qO- http://localhost/fail
```

```text
frontend-8b6f5c7d9-4kq2m: /healthz meldet jetzt 500
```

Terminal 2 nach ca. 10 Sekunden:

```text
NAME                       READY   STATUS    RESTARTS   AGE
frontend-8b6f5c7d9-4kq2m   1/1     Running   0          2m
frontend-8b6f5c7d9-9wz7t   1/1     Running   0          2m
frontend-8b6f5c7d9-tr5ln   1/1     Running   0          2m
frontend-8b6f5c7d9-4kq2m   0/1     Running   0          2m12s
```

## Aufgabe 3: Pod ist aus dem Verkehr

```bash
kubectl describe endpointslices -l kubernetes.io/service-name=frontend
for i in 1 2 3 4 5; do curl -s http://hello.localhost/ | grep Frontend-Pod; done
```

```text
Endpoints:
  - Addresses:  10.1.0.101
    Conditions:
      Ready:    false
    Hostname:   <unset>
    TargetRef:  Pod/frontend-8b6f5c7d9-4kq2m
    NodeName:   docker-desktop
  - Addresses:  10.1.0.102
    Conditions:
      Ready:    true
    TargetRef:  Pod/frontend-8b6f5c7d9-9wz7t
  - Addresses:  10.1.0.103
    Conditions:
      Ready:    true
    TargetRef:  Pod/frontend-8b6f5c7d9-tr5ln

  <p><b>Frontend-Pod:</b> frontend-8b6f5c7d9-9wz7t (10.1.0.102)</p>
  <p><b>Frontend-Pod:</b> frontend-8b6f5c7d9-tr5ln (10.1.0.103)</p>
  <p><b>Frontend-Pod:</b> frontend-8b6f5c7d9-9wz7t (10.1.0.102)</p>
  <p><b>Frontend-Pod:</b> frontend-8b6f5c7d9-tr5ln (10.1.0.103)</p>
  <p><b>Frontend-Pod:</b> frontend-8b6f5c7d9-9wz7t (10.1.0.102)</p>
```

Der Pod bleibt in der EndpointSlice, aber mit `Ready: false`; Service und Gateway schicken nur an bereite Pods. Für Besucher bleibt die Seite erreichbar.

## Aufgabe 4: Liveness startet den Container neu

Terminal 2 nach ca. 30 Sekunden:

```text
frontend-8b6f5c7d9-4kq2m   0/1     Running   1 (2s ago)   2m45s
frontend-8b6f5c7d9-4kq2m   1/1     Running   1 (7s ago)   2m50s
```

```bash
kubectl describe pod frontend-8b6f5c7d9-4kq2m
```

```text
Events:
  Type     Reason     Age                From     Message
  ----     ------     ----               ----     -------
  Warning  Unhealthy  45s (x5 over 65s)  kubelet  Readiness probe failed: HTTP probe failed with statuscode: 500
  Warning  Unhealthy  45s (x3 over 65s)  kubelet  Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    45s                kubelet  Container frontend failed liveness probe, will be restarted
  Normal   Pulled     44s                kubelet  Container image "hello-frontend:v2" already present on machine
  Normal   Started    44s                kubelet  Started container frontend
```

Der neue Prozess startet mit `/healthz` = `200`; der Schalter aus `/fail` gilt nur bis zum Neustart. Readiness hat nach 2 × 5 s reagiert, Liveness nach 3 × 10 s.

## Aufgabe 5: Rollout mit falscher Readiness-Probe

```yaml
          readinessProbe:
            httpGet:
              path: /nope
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
# nach ca. 30 Sekunden Strg+C
kubectl get pods -l tier=frontend
curl -s http://hello.localhost/ | grep Hello-App
```

```text
deployment.apps/frontend configured
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
^C
NAME                       READY   STATUS    RESTARTS   AGE
frontend-6d9c4b8f7-xk8vn   0/1     Running   0          35s
frontend-8b6f5c7d9-4kq2m   1/1     Running   1          4m
frontend-8b6f5c7d9-9wz7t   1/1     Running   0          4m
frontend-8b6f5c7d9-tr5ln   1/1     Running   0          4m

<head><meta charset="utf-8"><title>Hello-App v2</title></head>
  <h1>Hello-App v2</h1>
```

`/nope` liefert `404`, der neue Pod wird nie bereit. Wegen `maxUnavailable: 0` bleiben alle drei alten Pods in Betrieb. Die Liveness-Probe prüft weiter `/healthz` und ist zufrieden, deshalb gibt es keine Neustarts.

Zurücksetzen:

```bash
# path wieder auf /healthz setzen
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
```

```text
deployment "frontend" successfully rolled out
```

Gleichwertig: `kubectl rollout undo deployment/frontend` (Lab 4.3); danach trotzdem die Datei korrigieren, sonst bringt das nächste `kubectl apply` den Fehler zurück.

## Erweiterung

Mit `STARTUP_DELAY: "45"` und ohne Startup-Probe beginnt die Liveness-Probe sofort: drei Fehlschläge (`connection refused`) nach rund 30 Sekunden, Neustart, und der Start beginnt von vorn.

```text
frontend-7c5d8b9f6-q2mzx   0/1     Running            1 (3s ago)    38s
frontend-7c5d8b9f6-q2mzx   0/1     Running            2 (2s ago)    72s
frontend-7c5d8b9f6-q2mzx   0/1     CrashLoopBackOff   2 (1s ago)    101s
```

Mit Startup-Probe (bis 60 s) ruhen Liveness und Readiness, bis `/healthz` nach etwa 45 Sekunden antwortet:

```yaml
          env:
            - name: STARTUP_DELAY
              value: "45"
          startupProbe:
            httpGet:
              path: /healthz
              port: 80
            periodSeconds: 5
            failureThreshold: 12
```

```text
frontend-5f7b6c9d8-h8w2p   0/1     Running   0          40s
frontend-5f7b6c9d8-h8w2p   1/1     Running   0          50s
```

`RESTARTS` bleibt `0`. In beiden Fällen läuft die Seite weiter, weil die alten Pods bis zum Ende des Rollouts bleiben. Danach `env` und `startupProbe` entfernen und die Datei anwenden.
