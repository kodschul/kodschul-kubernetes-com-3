# Lab 3.4 – Lösung: Pod-Fehler lesen

Alle Befehle laufen im Ordner `project/`. Zeiten und Zähler weichen im eigenen Cluster ab.

## Aufgabe 1: Fehlerbilder anwenden

```bash
cp -r variants/m03-l04-pod-errors playground/pod-errors
kubectl apply -f playground/pod-errors/
kubectl get pods -l lab=pod-errors
```

```text
pod/fehler-image created
pod/fehler-crash created
pod/fehler-pending created
NAME             READY   STATUS              RESTARTS      AGE
fehler-crash     0/1     CrashLoopBackOff    2 (15s ago)   32s
fehler-image     0/1     ErrImageNeverPull   0             32s
fehler-pending   0/1     Pending             0             32s
```

## Aufgabe 2: fehler-image

```bash
kubectl describe pod fehler-image
```

```text
Events:
  Type     Reason             Age               From               Message
  ----     ------             ----              ----               -------
  Normal   Scheduled          50s               default-scheduler  Successfully assigned hello/fehler-image to docker-desktop
  Warning  ErrImageNeverPull  5s (x5 over 50s)  kubelet            Container image "hello-frontend:v9" is not present with pull policy of Never
  Warning  Failed             5s (x5 over 50s)  kubelet            Error: ErrImageNeverPull
```

Ursache (Umgebung): Ein Image `hello-frontend:v9` gibt es nicht; lokal existieren nur `v1` und `v2` (`docker images --filter "reference=hello-*"`). Korrektur in `playground/pod-errors/1-image-tag.yaml`:

```yaml
      image: hello-frontend:v1
```

```bash
kubectl apply -f playground/pod-errors/1-image-tag.yaml
kubectl get pod fehler-image
```

```text
pod/fehler-image configured
NAME           READY   STATUS    RESTARTS   AGE
fehler-image   1/1     Running   0          1m
```

Das Image darf sich am laufenden Pod ändern, daher reicht `apply`.

## Aufgabe 3: fehler-crash

```bash
kubectl logs fehler-crash --previous
kubectl describe pod fehler-crash
```

```text
python: can't open file '/app/server.py': [Errno 2] No such file or directory

Containers:
  backend:
    Image:         hello-backend:v1
    Command:
      python
      server.py
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    2
    Restart Count:  4
...
Events:
  Warning  BackOff  10s (x8 over 1m)  kubelet  Back-off restarting failed container backend in pod fehler-crash_hello(...)
```

Ursache (Programmstart): `command` startet `server.py`, im Image heißt die Datei `app.py`. Korrektur in `playground/pod-errors/2-crash.yaml`, entweder die Zeile `command` löschen (dann gilt `CMD ["python", "app.py"]` aus dem Dockerfile) oder:

```yaml
      command: ["python", "app.py"]
```

```bash
kubectl delete pod fehler-crash
kubectl apply -f playground/pod-errors/2-crash.yaml
```

`command` darf sich am laufenden Pod nicht ändern, deshalb löschen und neu anlegen.

## Aufgabe 4: fehler-pending

```bash
kubectl events --for pod/fehler-pending
```

```text
LAST SEEN   TYPE      REASON             OBJECT               MESSAGE
2m          Warning   FailedScheduling   Pod/fehler-pending   0/1 nodes are available: 1 Insufficient cpu. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.
```

Ursache (Umgebung): Der Pod reserviert 64 CPU-Kerne; der Node `docker-desktop` hat nur so viele, wie Docker Desktop zugeteilt bekommt. Korrektur in `playground/pod-errors/3-pending.yaml`:

```yaml
      resources:
        requests:
          cpu: "100m"                # 100 Milli-CPU = 0,1 Kern
```

```bash
kubectl delete pod fehler-pending
kubectl apply -f playground/pod-errors/3-pending.yaml
```

## Aufgabe 5: prüfen und aufräumen

```bash
kubectl get pods -l lab=pod-errors
kubectl delete -f playground/pod-errors/
kubectl get pods
```

```text
NAME             READY   STATUS    RESTARTS   AGE
fehler-crash     1/1     Running   0          40s
fehler-image     1/1     Running   1          3m
fehler-pending   1/1     Running   0          20s
pod "fehler-image" deleted
pod "fehler-crash" deleted
pod "fehler-pending" deleted
NAME       READY   STATUS    RESTARTS   AGE
backend    1/1     Running   0          1h
frontend   2/2     Running   0          35m
```

`RESTARTS 1` bei `fehler-image` stammt vom Austausch des Images.

## Erweiterung: ImagePullBackOff

```bash
kubectl run fehler-pull --image=ngnix:1.30-alpine
kubectl get pod fehler-pull -w
```

```text
NAME          READY   STATUS             RESTARTS   AGE
fehler-pull   0/1     ContainerCreating  0          1s
fehler-pull   0/1     ErrImagePull       0          4s
fehler-pull   0/1     ImagePullBackOff   0          17s
```

`kubectl describe pod fehler-pull` zeigt `Failed to pull image "ngnix:1.30-alpine": ... pull access denied, repository does not exist or may require authorization`. Richtig wäre `nginx`. Aufräumen: `kubectl delete pod fehler-pull`.
