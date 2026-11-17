# Lab 3.1 – Lösung: Der erste Pod

Alle Befehle laufen im Ordner `project/`. IPs, Zeiten und Pod-Alter weichen im eigenen Cluster ab.

## Aufgabe 1: Backend-Pod anlegen

```bash
cp starters/m03-l01-backend-pod.yaml playground/k8s/backend-pod.yaml
```

Ergänzte Zeilen in `playground/k8s/backend-pod.yaml`:

```yaml
spec:
  containers:
    - name: backend
      image: hello-backend:v1
      imagePullPolicy: Never
      ports:
        - containerPort: 80
```

```bash
kubectl apply -f playground/k8s/backend-pod.yaml
kubectl get pods -o wide
```

```text
pod/backend created
NAME      READY   STATUS    RESTARTS   AGE   IP          NODE             NOMINATED NODE   READINESS GATES
backend   1/1     Running   0          5s    10.1.0.23   docker-desktop   <none>           <none>
```

Ohne `imagePullPolicy: Never` würde Kubernetes bei Tag `v1` `IfNotPresent` nutzen; das funktioniert meist auch, versucht aber einen Download von Docker Hub, sobald das Image auf dem Node fehlt.

## Aufgabe 2: Frontend-Pod mit BACKEND_URL

```bash
cp starters/m03-l01-frontend-pod.yaml playground/k8s/frontend-pod.yaml
```

```yaml
      ports:
        - containerPort: 80
      env:
        - name: BACKEND_URL
          value: "http://10.1.0.23"    # eigene Backend-IP aus Aufgabe 1
```

```bash
kubectl apply -f playground/k8s/frontend-pod.yaml
kubectl exec frontend -- wget -qO- http://10.1.0.23
```

```text
pod/frontend created
{"ip":"10.1.0.23","pod":"backend","time":"09:41:12","version":"v1"}
```

`wget` stammt aus dem Alpine-Basisimage des Frontends. Der Aufruf zeigt: Pods erreichen sich im Cluster direkt über ihre IP.

## Aufgabe 3: Port-Forward und Backend-Log

Zweites Terminal:

```bash
kubectl port-forward pod/frontend 8080:80
```

```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
```

Die Seite `http://localhost:8080` zeigt auf hellblauem Hintergrund:

```text
Hello-App v1
Frontend-Pod: frontend (10.1.0.24)
Backend: backend (10.1.0.23) um 09:42:03
Admin: kein Passwort gesetzt
```

„kein Passwort gesetzt" ist richtig so; das Passwort kommt in Lab 6.2.

```bash
kubectl logs backend
```

```text
Hello-Backend v1 auf Port 80
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:80
 * Running on http://10.1.0.23:80
Press CTRL+C to quit
10.1.0.24 - - [17/Nov/2026 09:41:12] "GET / HTTP/1.1" 200 -
10.1.0.24 - - [17/Nov/2026 09:42:03] "GET / HTTP/1.1" 200 -
```

Die Anfragen kommen von `10.1.0.24`, der IP des Frontend-Pods (die erste aus Aufgabe 2, die zweite aus dem Browser).

## Aufgabe 4: describe lesen

```bash
kubectl describe pod frontend
```

```text
Name:             frontend
Namespace:        hello
Node:             docker-desktop/192.168.65.3
Labels:           app=hello
                  tier=frontend
Status:           Running
IP:               10.1.0.24
Containers:
  frontend:
    Image:          hello-frontend:v1
    Port:           80/TCP
    State:          Running
    Ready:          True
    Restart Count:  0
    Environment:
      BACKEND_URL:  http://10.1.0.23
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  2m    default-scheduler  Successfully assigned hello/frontend to docker-desktop
  Normal  Pulled     2m    kubelet            Container image "hello-frontend:v1" already present on machine
  Normal  Created    2m    kubelet            Created container: frontend
  Normal  Started    2m    kubelet            Started container frontend
```

Die Events zeigen den Weg aus der Theorie: Scheduler teilt zu, kubelet findet das lokale Image, erzeugt und startet den Container. Gekürzt (`...`) sind Felder, die spätere Labs erklären.

## Aufgabe 5: Backend neu anlegen, Frontend nachziehen

```bash
kubectl delete pod backend
kubectl apply -f playground/k8s/backend-pod.yaml
kubectl get pods -o wide
```

```text
pod "backend" deleted
pod/backend created
NAME       READY   STATUS    RESTARTS   AGE   IP          NODE             NOMINATED NODE   READINESS GATES
backend    1/1     Running   0          4s    10.1.0.25   docker-desktop   <none>           <none>
frontend   1/1     Running   0          6m    10.1.0.24   docker-desktop   <none>           <none>
```

Die Seite meldet nach dem Neuladen:

```text
Backend: Backend nicht erreichbar (http://10.1.0.23): ConnectTimeout
```

Je nach Netz steht dort auch `ConnectionError`. Das Frontend fragt weiter die alte IP, unter der kein Pod mehr antwortet.

Neue IP in `playground/k8s/frontend-pod.yaml` eintragen (`value: "http://10.1.0.25"`), dann:

```bash
kubectl delete pod frontend
kubectl apply -f playground/k8s/frontend-pod.yaml
```

Löschen ist nötig, weil `env` in einem laufenden Pod nicht geändert werden darf. Ein `kubectl apply` ohne Löschen endet mit `The Pod "frontend" is invalid: spec: Forbidden: pod updates may not change fields other than ...`.

Das Port-Forward im zweiten Terminal hat sich mit dem alten Pod beendet; neu starten mit `kubectl port-forward pod/frontend 8080:80`. Die Seite zeigt wieder `Backend: backend (10.1.0.25) um ...` und eine neue Frontend-IP.

## Erweiterung: Headlamp

**Workloads → Pods → frontend** zeigt Status, IP und Events. Das Log-Symbol öffnet dieselbe Ausgabe wie `kubectl logs frontend`; das Terminal-Symbol öffnet eine Shell, in der `env | grep BACKEND` die Zeile `BACKEND_URL=http://10.1.0.25` ausgibt.
