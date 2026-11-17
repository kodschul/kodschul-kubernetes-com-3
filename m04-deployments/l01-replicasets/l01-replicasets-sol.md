# Lab 4.1 – Lösung: ReplicaSets und Self-Healing

Alle Befehle laufen im Ordner `project/`. Pod-Namen, IPs und Zeiten weichen im eigenen Cluster ab.

## Aufgabe 1: Einzel-Pod entfernen

```bash
kubectl delete pod frontend
kubectl get pod backend -o wide           # IP z. B. 10.1.0.25
rm playground/k8s/frontend-pod.yaml
```

```text
pod "frontend" deleted
```

Ohne das Löschen würde das ReplicaSet den Pod `frontend` (Labels `app=hello`, `tier=frontend`) übernehmen und nur zwei neue Pods anlegen.

## Aufgabe 2: ReplicaSet anlegen

```bash
cp starters/m04-l01-frontend-replicaset.yaml playground/k8s/frontend-replicaset.yaml
```

```yaml
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello
      tier: frontend
  template:
    ...
          env:
            - name: BACKEND_URL
              value: "http://10.1.0.25"   # eigene Backend-IP
```

```bash
kubectl apply -f playground/k8s/frontend-replicaset.yaml
kubectl get rs
kubectl get pods -o wide
```

```text
replicaset.apps/frontend created
NAME       DESIRED   CURRENT   READY   AGE
frontend   3         3         3       6s
NAME             READY   STATUS    RESTARTS   AGE   IP          NODE             NOMINATED NODE   READINESS GATES
backend          1/1     Running   0          1h    10.1.0.25   docker-desktop   <none>           <none>
frontend-7mh4d   1/1     Running   0          6s    10.1.0.31   docker-desktop   <none>           <none>
frontend-p9wzl   1/1     Running   0          6s    10.1.0.32   docker-desktop   <none>           <none>
frontend-x2kqp   1/1     Running   0          6s    10.1.0.30   docker-desktop   <none>           <none>
```

## Aufgabe 3: Self-Healing

```bash
kubectl get pods -l tier=frontend -w      # zweites Terminal
kubectl delete pod frontend-x2kqp         # erstes Terminal, eigenen Namen einsetzen
```

```text
frontend-x2kqp   1/1     Terminating         0          3m
frontend-c5r8n   0/1     Pending             0          0s
frontend-c5r8n   0/1     ContainerCreating   0          0s
frontend-c5r8n   1/1     Running             0          1s
```

Der Ersatz `frontend-c5r8n` hat einen neuen Namen und eine neue IP (`kubectl get pods -o wide`). `kubectl describe pod frontend-c5r8n` zeigt `Controlled By: ReplicaSet/frontend`.

## Aufgabe 4: vierter Pod mit passenden Labels

```bash
kubectl run extra --image=hello-frontend:v1 --image-pull-policy=Never --labels=app=hello,tier=frontend
```

```text
pod/extra created
extra            0/1     Pending             0          0s
extra            0/1     Terminating         0          0s
```

Das ReplicaSet zählt vier passende Pods bei Soll 3 und löscht einen. Es wählt bevorzugt einen Pod, der noch nicht bereit ist, hier den gerade gestarteten `extra`. `kubectl get pods -l tier=frontend` zeigt danach wieder drei Pods.

## Aufgabe 5: skalieren und zurücksetzen

```bash
kubectl scale rs frontend --replicas=5
kubectl get rs
kubectl apply -f playground/k8s/frontend-replicaset.yaml
kubectl get rs
```

```text
replicaset.apps/frontend scaled
NAME       DESIRED   CURRENT   READY   AGE
frontend   5         5         5       6m
replicaset.apps/frontend configured
NAME       DESIRED   CURRENT   READY   AGE
frontend   3         3         3       6m
```

Die Datei sagt `replicas: 3`; `apply` setzt das Soll zurück, und das ReplicaSet löscht zwei Pods. Wer dauerhaft fünf Pods will, ändert die Datei.
