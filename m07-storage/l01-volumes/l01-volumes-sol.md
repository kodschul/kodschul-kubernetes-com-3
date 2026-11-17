# Lab 7.1 – Lösung: Volumes

Alle Befehle laufen im Ordner `project/`. Pod-Namen, Zeiten und IPs weichen ab.

## Aufgabe 1: Log ohne Volume und Container-Neustart

```bash
kubectl scale deployment frontend --replicas=1
kubectl get pods -l tier=frontend
for i in 1 2 3; do curl -s -o /dev/null http://hello.localhost/; done
kubectl exec deploy/frontend -- cat /data/access.log
kubectl exec deploy/frontend -- kill -INT 1
kubectl exec deploy/frontend -- cat /data/access.log
kubectl get pods -l tier=frontend
```

```text
NAME                        READY   STATUS    RESTARTS   AGE
frontend-6c9d8f7b5d-x2kqp   1/1     Running   0          41m

2026-11-17T14:02:11 frontend-6c9d8f7b5d-x2kqp 10.1.0.84 v2
2026-11-17T14:02:11 frontend-6c9d8f7b5d-x2kqp 10.1.0.84 v2
2026-11-17T14:02:12 frontend-6c9d8f7b5d-x2kqp 10.1.0.84 v2

cat: can't open '/data/access.log': No such file or directory
command terminated with exit code 1

NAME                        READY   STATUS    RESTARTS      AGE
frontend-6c9d8f7b5d-x2kqp   1/1     Running   1 (8s ago)    42m
```

Ohne Volume lag das Log in der Container-Schicht; der neu gestartete Container beginnt mit einer leeren Schicht. Pod-Name und IP sind gleich geblieben, nur `RESTARTS` ist gestiegen. Meldet `kill` selbst `command terminated with exit code 137`, wurde der `kill`-Prozess beim Beenden des Containers mit abgeräumt; der Neustart hat trotzdem stattgefunden.

## Aufgabe 2: emptyDir-Volume anlegen

```bash
cp starters/m07-l01-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
# TODOs ergänzen (siehe unten)
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
```

Geänderte Stellen in `playground/k8s/frontend-deployment.yaml`:

```yaml
spec:
  replicas: 1
  ...
          volumeMounts:
            - name: data
              mountPath: /data
            - name: admin-secret
              mountPath: /etc/hello-secret
              readOnly: true
      volumes:
        - name: data
          emptyDir: {}
        - name: admin-secret
          secret:
            secretName: hello-secret
```

```text
deployment.apps/frontend configured
Waiting for deployment "frontend" rollout to finish: 1 old replicas are pending termination...
deployment "frontend" successfully rolled out
```

Vollständige Datei: [`examples/m07-storage/l01-volumes/frontend-deployment.yaml`](../../project/examples/m07-storage/l01-volumes/frontend-deployment.yaml)

## Aufgabe 3: Container-Neustart mit emptyDir

```bash
for i in 1 2 3; do curl -s -o /dev/null http://hello.localhost/; done
kubectl exec deploy/frontend -- cat /data/access.log
kubectl exec deploy/frontend -- kill -INT 1
kubectl exec deploy/frontend -- cat /data/access.log
kubectl get pods -l tier=frontend
```

```text
2026-11-17T14:05:40 frontend-7f4b9c6d8-m8zr2 10.1.0.91 v2
2026-11-17T14:05:40 frontend-7f4b9c6d8-m8zr2 10.1.0.91 v2
2026-11-17T14:05:41 frontend-7f4b9c6d8-m8zr2 10.1.0.91 v2

2026-11-17T14:05:40 frontend-7f4b9c6d8-m8zr2 10.1.0.91 v2
2026-11-17T14:05:40 frontend-7f4b9c6d8-m8zr2 10.1.0.91 v2
2026-11-17T14:05:41 frontend-7f4b9c6d8-m8zr2 10.1.0.91 v2

NAME                       READY   STATUS    RESTARTS     AGE
frontend-7f4b9c6d8-m8zr2   1/1     Running   1 (6s ago)   1m
```

Das `emptyDir` gehört zum Pod, nicht zum Container: Der neue Container findet die Datei wieder.

## Aufgabe 4: Pod-Ersatz mit emptyDir

```bash
kubectl delete pod -l tier=frontend
kubectl get pods -l tier=frontend
kubectl exec deploy/frontend -- cat /data/access.log
curl -s -o /dev/null http://hello.localhost/
kubectl exec deploy/frontend -- cat /data/access.log
```

```text
pod "frontend-7f4b9c6d8-m8zr2" deleted

NAME                       READY   STATUS    RESTARTS   AGE
frontend-7f4b9c6d8-qv7tn   1/1     Running   0          35s

cat: can't open '/data/access.log': No such file or directory
command terminated with exit code 1

2026-11-17T14:07:22 frontend-7f4b9c6d8-qv7tn 10.1.0.92 v2
```

Der Ersatz-Pod hat ein neues, leeres `emptyDir`. `kubectl delete pod` braucht hier rund 30 Sekunden, weil Python als PID 1 das Signal `SIGTERM` ignoriert und Kubernetes die Wartefrist abwartet.

## Aufgabe 5: Volume im Pod ansehen

```bash
kubectl describe pod -l tier=frontend
```

```text
Containers:
  frontend:
    ...
    Mounts:
      /data from data (rw)
      /etc/hello-secret from admin-secret (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7xk2p (ro)
...
Volumes:
  data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  admin-secret:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  hello-secret
    Optional:    false
```

Das dritte Volume `kube-api-access-…` legt Kubernetes in jedem Pod automatisch an (Zugangsdaten für die API, Lab 10.2); es kann vorerst ignoriert werden.

## Lebensdauer von access.log je Speicherort

| Speicherort von `access.log` | überlebt Container-Neustart | überlebt Pod-Löschung |
| --- | --- | --- |
| Container-Schicht (kein Volume) | nein (Aufgabe 1) | nein |
| `emptyDir` | ja (Aufgabe 3) | nein (Aufgabe 4) |
| `persistentVolumeClaim` | ja | ja (Lab 7.2) |

Fertiger Stand: [`examples/m07-storage/l01-volumes/`](../../project/examples/m07-storage/l01-volumes/)
