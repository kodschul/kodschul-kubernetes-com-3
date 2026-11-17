# Lab 7.2 – Lösung: PersistentVolumes und StorageClasses

Alle Befehle laufen im Ordner `project/`. Namen, Zeiten und IPs weichen ab.

## Aufgabe 1: StorageClass und PVC

```bash
kubectl get storageclass
cp starters/m07-l02-pvc.yaml playground/k8s/pvc.yaml
# TODOs ergänzen (siehe unten)
kubectl apply -f playground/k8s/pvc.yaml
kubectl get pvc,pv
```

```yaml
# playground/k8s/pvc.yaml, ergänzte Stellen
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```text
NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
hostpath (default)   docker.io/hostpath   Delete          Immediate           false                  12d

persistentvolumeclaim/hello-data created

NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/hello-data   Bound    pvc-3f1c2a7e-9b1d-4c55-8e0a-6d2f1b7c9a10   1Gi        RWO            hostpath       <unset>                 5s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-3f1c2a7e-9b1d-4c55-8e0a-6d2f1b7c9a10   1Gi        RWO            Delete           Bound    hello/hello-data   hostpath       <unset>                          5s
```

Das PV hat niemand von Hand angelegt: Der Provisioner der StorageClass `hostpath` hat es für den Claim erzeugt (dynamische Bereitstellung).

## Aufgabe 2: Frontend auf den PVC umstellen

```bash
cp starters/m07-l02-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
# TODO ergänzen (siehe unten)
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
for i in 1 2 3; do curl -s -o /dev/null http://hello.localhost/; done
kubectl exec deploy/frontend -- cat /data/access.log
```

```yaml
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: hello-data
```

```text
deployment.apps/frontend configured
deployment "frontend" successfully rolled out
2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:20:04 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
```

## Aufgabe 3: Pod löschen, Log bleibt

```bash
kubectl delete pod -l tier=frontend
kubectl get pods -l tier=frontend
kubectl exec deploy/frontend -- cat /data/access.log
curl -s -o /dev/null http://hello.localhost/
kubectl exec deploy/frontend -- cat /data/access.log
```

```text
pod "frontend-5d8c7b9f4-hk2vw" deleted
NAME                       READY   STATUS    RESTARTS   AGE
frontend-5d8c7b9f4-p9xtd   1/1     Running   0          32s

2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:20:04 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2

2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:20:04 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
2026-11-17T14:21:10 frontend-5d8c7b9f4-p9xtd 10.1.0.96 v2
```

Der Ersatz-Pod hängt dasselbe PV ein und schreibt weiter in dieselbe Datei.

## Aufgabe 4: Drei Repliken auf einem RWO-Volume

```yaml
spec:
  replicas: 3
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
for i in 1 2 3 4 5 6; do curl -s -o /dev/null http://hello.localhost/; done
kubectl exec deploy/frontend -- cat /data/access.log
kubectl get pods -l tier=frontend -o wide
```

```text
...
2026-11-17T14:23:30 frontend-5d8c7b9f4-p9xtd 10.1.0.96 v2
2026-11-17T14:23:30 frontend-5d8c7b9f4-7rjq4 10.1.0.97 v2
2026-11-17T14:23:30 frontend-5d8c7b9f4-c4zn8 10.1.0.98 v2
2026-11-17T14:23:31 frontend-5d8c7b9f4-p9xtd 10.1.0.96 v2
2026-11-17T14:23:31 frontend-5d8c7b9f4-7rjq4 10.1.0.97 v2
2026-11-17T14:23:31 frontend-5d8c7b9f4-c4zn8 10.1.0.98 v2

NAME                       READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
frontend-5d8c7b9f4-7rjq4   1/1     Running   0          40s     10.1.0.97    docker-desktop   <none>           <none>
frontend-5d8c7b9f4-c4zn8   1/1     Running   0          40s     10.1.0.98    docker-desktop   <none>           <none>
frontend-5d8c7b9f4-p9xtd   1/1     Running   0          3m      10.1.0.96    docker-desktop   <none>           <none>
```

`ReadWriteOnce` erlaubt einen Node. Alle drei Pods laufen auf `docker-desktop`, also dürfen alle drei schreiben. Mit mehreren Nodes würde ein Pod auf einem zweiten Node mit `Multi-Attach error` in `ContainerCreating` hängen bleiben. Dass mehrere Prozesse ohne Absprache an dieselbe Datei anhängen, geht bei kurzen Zeilen meist gut; für echte Daten braucht es eine Datenbank oder je Pod ein eigenes Volume.

## Aufgabe 5: Wer nutzt den Claim?

```bash
kubectl describe pvc hello-data
```

```text
Name:          hello-data
Namespace:     hello
StorageClass:  hostpath
Status:        Bound
Volume:        pvc-3f1c2a7e-9b1d-4c55-8e0a-6d2f1b7c9a10
...
Capacity:      1Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       frontend-5d8c7b9f4-7rjq4
               frontend-5d8c7b9f4-c4zn8
               frontend-5d8c7b9f4-p9xtd
Events:        <none>
```

## Erweiterung

```bash
kubectl describe pv
```

Unter `Source` steht bei Docker Desktop `Type: HostPath` mit einem Ordner auf dem Node, in dem der Provisioner je Claim ein Unterverzeichnis anlegt (genauer Pfad: siehe Ausgabe).

Fertiger Stand: [`examples/m07-storage/l02-persistent-volumes/`](../../project/examples/m07-storage/l02-persistent-volumes/)
