# Lab 8.2 – Lösung: Requests, Limits und QoS

Alle Befehle laufen im Ordner `project/`. Namen, Zeiten und Prozentwerte weichen ab.

## Aufgabe 1: Requests und Limits setzen

```bash
cp starters/m08-l02-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
cp starters/m08-l02-backend-deployment.yaml playground/k8s/backend-deployment.yaml
# TODOs ergänzen (siehe unten)
kubectl apply -f playground/k8s/frontend-deployment.yaml -f playground/k8s/backend-deployment.yaml
kubectl rollout status deployment/frontend
kubectl rollout status deployment/backend
```

Frontend:

```yaml
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 500m
              memory: 128Mi
```

Backend:

```yaml
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 200m
              memory: 128Mi
```

Vollständige Dateien: [`examples/m08-health-resources/l02-resources/`](../../project/examples/m08-health-resources/l02-resources/)

## Aufgabe 2: QoS-Klasse und Node-Auslastung

```bash
kubectl get pods -l app=hello -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
kubectl describe node docker-desktop
```

```text
NAME                              QOS
backend-7d9f6c5b8-2xq7n           Burstable
backend-7d9f6c5b8-8kd4w           Burstable
backend-7d9f6c5b8-vt5mj           Burstable
frontend-6f8d7c9b5-4hx2p          Burstable
frontend-6f8d7c9b5-k9w3z          Burstable
frontend-6f8d7c9b5-r7m5t          Burstable
hello-backup-29384540-q8zjk       BestEffort
```

Die Job-Pods des CronJobs (Lab 7.3) haben keine Requests und Limits und sind deshalb `BestEffort`.

```text
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                1300m (16%)   2100m (26%)
  memory             714Mi (9%)    1438Mi (18%)
```

Die Werte enthalten auch die Systempods in `kube-system`, `envoy-gateway-system` und `gateway`. Limits dürfen in Summe über 100 % liegen (Überbuchung); Requests nicht.

## Aufgabe 3: Zu kleines Memory-Limit

```yaml
              memory: 16Mi     # requests
            ...
              memory: 16Mi     # limits
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
# Terminal 2
kubectl get pods -l tier=frontend -w
```

```text
NAME                       READY   STATUS              RESTARTS     AGE
frontend-6f8d7c9b5-4hx2p   1/1     Running             0            6m
frontend-6f8d7c9b5-k9w3z   1/1     Running             0            6m
frontend-6f8d7c9b5-r7m5t   1/1     Running             0            6m
frontend-58c4d9f7b6-wz2kq  0/1     ContainerCreating   0            1s
frontend-58c4d9f7b6-wz2kq  0/1     OOMKilled           0            3s
frontend-58c4d9f7b6-wz2kq  0/1     OOMKilled           1 (2s ago)   5s
frontend-58c4d9f7b6-wz2kq  0/1     CrashLoopBackOff    1 (3s ago)   7s
frontend-58c4d9f7b6-wz2kq  0/1     OOMKilled           2 (16s ago)  21s
frontend-58c4d9f7b6-wz2kq  0/1     CrashLoopBackOff    2 (12s ago)  32s
```

```bash
kubectl describe pod frontend-58c4d9f7b6-wz2kq
```

```text
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Tue, 17 Nov 2026 15:02:41 +0100
      Finished:     Tue, 17 Nov 2026 15:02:42 +0100
    Ready:          False
    Restart Count:  2
    Limits:
      cpu:     500m
      memory:  16Mi
```

Python mit Flask braucht schon beim Laden der Bibliotheken mehr als 16 MiB; der Kernel beendet den Prozess (Exit-Code 137 = 128 + Signal 9, `SIGKILL`). Dank Readiness-Probe (Lab 8.1) und `maxUnavailable: 0` bleiben die alten Pods in Betrieb.

## Aufgabe 4: Werte zurücksetzen

```bash
# memory wieder: requests 64Mi, limits 128Mi
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
```

```text
deployment.apps/frontend configured
deployment "frontend" successfully rolled out
```

## Aufgabe 5: CPU-Limit im laufenden Pod ändern

```bash
kubectl get pods -l tier=frontend
kubectl patch pod frontend-6f8d7c9b5-4hx2p --subresource resize --patch \
  '{"spec":{"containers":[{"name":"frontend","resources":{"limits":{"cpu":"800m"}}}]}}'
kubectl get pod frontend-6f8d7c9b5-4hx2p -o jsonpath='{.spec.containers[0].resources.limits.cpu}'; echo
kubectl get pod frontend-6f8d7c9b5-4hx2p -o jsonpath='{.status.containerStatuses[0].resources.limits.cpu}'; echo
kubectl get pod frontend-6f8d7c9b5-4hx2p -o jsonpath='{.status.containerStatuses[0].restartCount}'; echo
kubectl get deployment frontend -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}'; echo
```

```text
pod/frontend-6f8d7c9b5-4hx2p patched
800m
800m
0
500m
```

`echo` sorgt nur für einen Zeilenumbruch nach der Ausgabe. CPU hat die Standard-`resizePolicy` `NotRequired`: Der kubelet ändert die Grenze im laufenden Container. Request (100m) und Limit (800m) bleiben verschieden, die QoS-Klasse bleibt `Burstable`. Das Deployment kennt die Änderung nicht.

## Erweiterung

```bash
kubectl delete pod frontend-6f8d7c9b5-4hx2p
kubectl get pods -l tier=frontend
kubectl get pod <neuer Pod> -o jsonpath='{.spec.containers[0].resources.limits.cpu}'; echo
```

```text
500m
```

Dauerhafte Änderungen gehören ins Manifest; In-place-Resize hilft, einen laufenden Pod kurzfristig zu entlasten, ohne ihn neu zu starten.
