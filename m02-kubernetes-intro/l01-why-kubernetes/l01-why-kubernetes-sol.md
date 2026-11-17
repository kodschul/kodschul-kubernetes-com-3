# Lab 2.1 – Lösung: Warum Kubernetes?

Die Befehle der Demo zum Nachlesen; die Ausgaben stammen aus einem Docker-Desktop-Cluster, Namen und IPs weichen bei jedem Lauf ab.

## Aufgabe 1: Drei Kopien starten

```bash
kubectl create deployment hello-demo --image=hello-backend:v1 --replicas=3
kubectl get pods -o wide
```

```text
deployment.apps/hello-demo created
NAME                          READY   STATUS    RESTARTS   AGE   IP          NODE             NOMINATED NODE   READINESS GATES
hello-demo-6c9f7d8b5d-2xkqp   1/1     Running   0          6s    10.1.0.21   docker-desktop   <none>           <none>
hello-demo-6c9f7d8b5d-8hz4w   1/1     Running   0          6s    10.1.0.22   docker-desktop   <none>           <none>
hello-demo-6c9f7d8b5d-tq7mn   1/1     Running   0          6s    10.1.0.23   docker-desktop   <none>           <none>
```

Ein Befehl beschreibt den gewünschten Zustand („3 Kopien"), Kubernetes erzeugt die Kopien selbst. Eine Kopie heißt in Kubernetes **Pod** (Lab 3.1), der Befehl erzeugt ein **Deployment** (Lab 4.2).

## Aufgabe 2: Antworten unter einer gemeinsamen Adresse

```bash
kubectl expose deployment hello-demo --type=LoadBalancer --port=8090 --target-port=80
for i in 1 2 3 4 5; do curl -s http://localhost:8090; echo; done
```

```text
{"ip":"10.1.0.22","pod":"hello-demo-6c9f7d8b5d-8hz4w","time":"10:48:02","version":"v1"}
{"ip":"10.1.0.21","pod":"hello-demo-6c9f7d8b5d-2xkqp","time":"10:48:02","version":"v1"}
{"ip":"10.1.0.22","pod":"hello-demo-6c9f7d8b5d-8hz4w","time":"10:48:02","version":"v1"}
{"ip":"10.1.0.23","pod":"hello-demo-6c9f7d8b5d-tq7mn","time":"10:48:03","version":"v1"}
{"ip":"10.1.0.21","pod":"hello-demo-6c9f7d8b5d-2xkqp","time":"10:48:03","version":"v1"}
```

Die gemeinsame Adresse `localhost:8090` verteilt die Anfragen auf alle drei Kopien (Service, Modul 5).

## Aufgabe 3: Eine Kopie löschen

```bash
kubectl delete pod hello-demo-6c9f7d8b5d-8hz4w
kubectl get pods -o wide -w
```

```text
pod "hello-demo-6c9f7d8b5d-8hz4w" deleted
NAME                          READY   STATUS        RESTARTS   AGE   IP          …
hello-demo-6c9f7d8b5d-2xkqp   1/1     Running       0          3m    10.1.0.21
hello-demo-6c9f7d8b5d-8hz4w   1/1     Terminating   0          3m    10.1.0.22
hello-demo-6c9f7d8b5d-tq7mn   1/1     Running       0          3m    10.1.0.23
hello-demo-6c9f7d8b5d-m4v9r   1/1     Running       0          2s    10.1.0.24
```

`Strg+C` beendet die Beobachtung (`-w` = watch).

## Aufgabe 4: Wieder drei Kopien

Gewünscht sind drei, kurz waren es zwei: Kubernetes hat die Abweichung bemerkt und `hello-demo-…-m4v9r` mit der neuen IP `10.1.0.24` gestartet. Das ist der Regelkreis aus der Theorie. Die Demo endet mit:

```bash
kubectl delete service,deployment hello-demo
```

## Erweiterung: Nachspielen nach Lab 4.2

```bash
kubectl create deployment hello-demo --image=hello-backend:v1 --replicas=3
kubectl get pods -o wide -l app=hello-demo
kubectl get pods -o wide -l app=hello-demo -w          # zweites Terminal
kubectl delete pod hello-demo-6c9f7d8b5d-2xkqp          # Namen aus der eigenen Liste
kubectl delete deployment hello-demo
```

Die Ausgaben gleichen Aufgabe 1 und 3. `-l app=hello-demo` zeigt nur die Demo-Kopien, nicht die Hello-App; `kubectl create deployment` vergibt dieses Label automatisch (Labels: Lab 3.3).
