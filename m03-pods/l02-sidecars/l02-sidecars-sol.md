# Lab 3.2 – Lösung: Mehrere Container in einem Pod

Alle Befehle laufen im Ordner `project/`. IPs und Zeiten weichen im eigenen Cluster ab.

## Aufgabe 1: Starter ergänzen

```bash
kubectl get pod backend -o wide          # IP z. B. 10.1.0.25
cp starters/m03-l02-frontend-pod.yaml playground/k8s/frontend-pod.yaml
```

```yaml
# playground/k8s/frontend-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    app: hello
    tier: frontend
spec:
  initContainers:
    - name: log-reader
      image: busybox:1.37
      restartPolicy: Always            # Sidecar: läuft neben dem Frontend weiter
      command: ["sh", "-c", "touch /data/access.log && tail -F /data/access.log"]
      volumeMounts:
        - name: data
          mountPath: /data
  containers:
    - name: frontend
      image: hello-frontend:v1
      imagePullPolicy: Never
      ports:
        - containerPort: 80
      env:
        - name: BACKEND_URL
          value: "http://10.1.0.25"    # eigene Backend-IP
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      emptyDir: {}
```

## Aufgabe 2: Pod neu anlegen und Start beobachten

```bash
kubectl delete pod frontend
kubectl apply -f playground/k8s/frontend-pod.yaml
kubectl get pod frontend -w
```

```text
pod "frontend" deleted
pod/frontend created
NAME       READY   STATUS            RESTARTS   AGE
frontend   0/2     Init:0/1          0          1s
frontend   1/2     PodInitializing   0          3s
frontend   2/2     Running           0          4s
```

`Init:0/1` heißt: der Sidecar startet noch; erst danach startet das Frontend. Beim ersten Mal dauert es etwas länger, weil der Node `busybox:1.37` von Docker Hub lädt.

## Aufgabe 3: Seite aufrufen

```bash
kubectl port-forward pod/frontend 8080:80    # zweites Terminal
```

Die Seite zeigt wie in Lab 3.1 „Hello-App v1" mit Backend-Antwort, nur mit neuer Frontend-IP.

## Aufgabe 4: Sidecar-Log lesen

```bash
kubectl logs frontend -c log-reader
```

```text
2026-11-17T10:05:41 frontend 10.1.0.26 v1
2026-11-17T10:05:43 frontend 10.1.0.26 v1
2026-11-17T10:05:44 frontend 10.1.0.26 v1
```

```bash
kubectl logs -f frontend -c log-reader       # nach jedem Neuladen eine neue Zeile, Ende mit Strg+C
```

Zum Vergleich zeigt `kubectl logs frontend` (ohne `-c`) die Flask-Ausgabe des Frontends mit `"GET / HTTP/1.1" 200`-Zeilen, vorneweg der Hinweis `Defaulted container "frontend" out of: frontend, log-reader (init)`.

## Aufgabe 5: gemeinsame Datei und describe

```bash
kubectl exec frontend -c frontend -- cat /data/access.log
```

```text
2026-11-17T10:05:41 frontend 10.1.0.26 v1
2026-11-17T10:05:43 frontend 10.1.0.26 v1
2026-11-17T10:05:44 frontend 10.1.0.26 v1
```

Dieselben Zeilen wie im Sidecar-Log: beide Container sehen das Volume `data` unter `/data`.

```bash
kubectl describe pod frontend
```

```text
Init Containers:
  log-reader:
    Image:         busybox:1.37
    Command:
      sh
      -c
      touch /data/access.log && tail -F /data/access.log
    State:          Running
    Ready:          True
    Restart Count:  0
    Restart Policy: Always
    Mounts:
      /data from data (rw)
Containers:
  frontend:
    Image:          hello-frontend:v1
    State:          Running
    Mounts:
      /data from data (rw)
...
Volumes:
  data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
```

Gekürzt auf die Teile dieses Labs.

## Erweiterung: emptyDir lebt so lange wie der Pod

```bash
kubectl delete pod frontend
kubectl apply -f playground/k8s/frontend-pod.yaml
kubectl logs frontend -c log-reader
```

Die Ausgabe ist leer, bis die Seite wieder aufgerufen wird (Port-Forward neu starten). Mit dem Pod wurde auch das `emptyDir` gelöscht. Wie Daten einen Pod überleben, zeigt Lab 7.2.
