# Lab 11.1 – Lösung: Fehlersuche mit System

Pod-Namen, IPs und Zeiten weichen in jedem Cluster ab; die Struktur der Ausgaben bleibt gleich.

## Aufgabe 1: Fehlerbild 1 anwenden und Symptom lesen

```bash
cp -r variants/m11-l01-troubleshooting/fehler-1 playground/k8s/m11-fehler-1
kubectl apply -f playground/k8s/m11-fehler-1/
```

```text
namespace/hello-debug created
deployment.apps/backend created
service/backend created
configmap/hello-config created
deployment.apps/frontend created
service/frontend created
```

```bash
kubectl get pods -n hello-debug
```

```text
NAME                        READY   STATUS    RESTARTS   AGE
backend-5c7d9b6f4-2xq8n     1/1     Running   0          20s
frontend-7f6b8d9c5-rv4lm    1/1     Running   0          20s
```

Beide Pods laufen und sind bereit. Der Port-Forward startet, scheitert aber beim ersten Aufruf (gekürzt):

```text
Forwarding from 127.0.0.1:8083 -> 8080
Forwarding from [::1]:8083 -> 8080
Handling connection for 8083
E1117 14:05:12.345678 ... an error occurred forwarding 8083 -> 8080: error forwarding port 8080 to pod ..., failed to connect to localhost:8080 inside namespace ...: connect: connection refused
```

`curl -s http://localhost:8083/` endet mit `curl: (52) Empty reply from server`, der Browser zeigt „Seite nicht erreichbar" (`ERR_EMPTY_RESPONSE`). Schon die erste Zeile verrät den Zielport `8080`.

## Aufgabe 2: Ursache von außen nach innen suchen

Service und EndpointSlice:

```bash
kubectl describe svc frontend -n hello-debug
kubectl get endpointslices -n hello-debug -l kubernetes.io/service-name=frontend
```

```text
Name:              frontend
Namespace:         hello-debug
Selector:          app=hello,tier=frontend
Type:              ClusterIP
Port:              <unset>  80/TCP
TargetPort:        8080/TCP                 # <- Ziel im Container
Endpoints:         10.1.0.57:8080
...
NAME             ADDRESSTYPE   PORTS   ENDPOINTS   AGE
frontend-k2w9d   IPv4          8080    10.1.0.57   1m
```

Der Service hat einen Endpunkt, der Selector passt also. Weiter zum Pod:

```bash
kubectl describe pod -n hello-debug -l tier=frontend | grep -A3 "frontend:"
```

```text
  frontend:
    Container ID:   containerd://...
    Image:          hello-frontend:v1
    Port:           80/TCP                   # <- der Container lauscht auf 80
```

Pod direkt, ohne Service (zweites Terminal):

```bash
kubectl port-forward -n hello-debug pod/frontend-7f6b8d9c5-rv4lm 8084:80
curl -s http://localhost:8084/ | grep "<h1>"
```

```text
  <h1>Hello-App v1</h1>
```

Der Pod antwortet, der Fehler liegt also davor. Gegenprobe im Container:

```bash
kubectl debug -it frontend-7f6b8d9c5-rv4lm -n hello-debug --image=busybox:1.37 --target=frontend
```

```text
/ # netstat -tln
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
/ # wget -qO- http://localhost:8080/healthz
wget: can't connect to remote host (127.0.0.1): Connection refused
/ # wget -qO- http://localhost:80/healthz
ok
/ # exit
```

Die Ursache liegt an der Station Service: `targetPort: 8080` im Service `frontend`, das Programm lauscht aber auf Port 80. Gezeigt haben es `kubectl describe svc` (TargetPort) zusammen mit `describe pod` (Port) und `netstat` im Debug-Container.

## Aufgabe 3: Fehlerbild 1 beheben

`playground/k8s/m11-fehler-1/frontend-service.yaml`:

```yaml
  ports:
    - port: 80                          # Port des Service
      targetPort: 80                    # Port im Container
```

```bash
kubectl apply -f playground/k8s/m11-fehler-1/
kubectl port-forward -n hello-debug svc/frontend 8083:80
```

```text
service/frontend configured
...
Forwarding from 127.0.0.1:8083 -> 80
```

`http://localhost:8083` zeigt „Hello-App v1" auf rosa Hintergrund (`APP_COLOR: lightpink` aus der ConfigMap) und unter **Backend** die Antwort des Backend-Pods.

Alternative ohne Datei: `kubectl patch svc frontend -n hello-debug -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'`. Die Datei zu ändern ist besser: sonst stellt das nächste `kubectl apply` den Fehler wieder her.

## Aufgabe 4: Fehlerbild 2 finden und beheben

```bash
kubectl delete namespace hello-debug
cp -r variants/m11-l01-troubleshooting/fehler-2 playground/k8s/m11-fehler-2
kubectl apply -f playground/k8s/m11-fehler-2/
kubectl get pods -n hello-debug
```

```text
NAME                        READY   STATUS                       RESTARTS   AGE
backend-5c7d9b6f4-8hd2c     1/1     Running                      0          15s
frontend-6d9f7c8b5-qk4tz    0/1     CreateContainerConfigError   0          15s
```

Der Port-Forward bricht sofort ab, weil kein Frontend-Pod läuft:

```text
error: unable to forward port because pod is not running. Current status=Pending
```

Events des Pods:

```bash
kubectl events -n hello-debug --for pod/frontend-6d9f7c8b5-qk4tz
```

```text
LAST SEEN   TYPE      REASON      OBJECT                         MESSAGE
20s         Normal    Scheduled   Pod/frontend-6d9f7c8b5-qk4tz   Successfully assigned hello-debug/frontend-6d9f7c8b5-qk4tz to docker-desktop
5s          Warning   Failed      Pod/frontend-6d9f7c8b5-qk4tz   Error: couldn't find key APP_COLOR in ConfigMap hello-debug/hello-config
```

Die Ursache liegt an der Station Pod: Das Deployment holt `APP_COLOR` per `configMapKeyRef` aus der ConfigMap `hello-config`, dort fehlt der Schlüssel. Gezeigt hat es `kubectl events --for pod/...` (oder der Abschnitt `Events` in `kubectl describe pod`).

Behebung in `playground/k8s/m11-fehler-2/configmap.yaml`:

```yaml
data:
  BACKEND_URL: http://backend
  APP_COLOR: lightpink
```

```bash
kubectl apply -f playground/k8s/m11-fehler-2/
kubectl get pods -n hello-debug -w
```

```text
configmap/hello-config configured
...
NAME                        READY   STATUS                       RESTARTS   AGE
frontend-6d9f7c8b5-qk4tz    0/1     CreateContainerConfigError   0          2m
frontend-6d9f7c8b5-qk4tz    0/1     Running                      0          2m10s
frontend-6d9f7c8b5-qk4tz    1/1     Running                      0          2m15s
```

Der Pod bleibt derselbe: Kubernetes versucht das Anlegen des Containers regelmäßig neu und hat Erfolg, sobald der Schlüssel existiert.

Weitere gültige Lösungen:

- den `env`-Eintrag `APP_COLOR` aus `frontend-deployment.yaml` entfernen (dann gilt die Farbe aus dem Image, hellblau),
- `optional: true` unter `configMapKeyRef` setzen (fehlender Schlüssel wird dann übersprungen).

## Aufgabe 5: Prüfen und aufräumen

```bash
kubectl port-forward -n hello-debug svc/frontend 8083:80   # Seite rosa, Backend antwortet; dann Strg+C
kubectl delete namespace hello-debug
kubectl get namespace hello-debug
```

```text
namespace "hello-debug" deleted
Error from server (NotFound): namespaces "hello-debug" not found
```

| Fehler | Station | Befehl, der die Ursache gezeigt hat |
| --- | --- | --- |
| 1: `targetPort: 8080` statt 80 | Service | `kubectl describe svc` + `describe pod` / `netstat` im Debug-Container |
| 2: Schlüssel `APP_COLOR` fehlt in der ConfigMap | Pod | `kubectl events --for pod/...` |

## Erweiterung: Fehlerbild 3

```bash
cp -r variants/m11-l01-troubleshooting/fehler-3 playground/k8s/m11-fehler-3
kubectl apply -f playground/k8s/m11-fehler-3/
kubectl run test -n hello-debug --rm -it --restart=Never --image=busybox:1.37 -- wget -qO- -T 3 http://frontend
```

```text
wget: can't connect to remote host (10.105.31.12): Connection refused
pod "test" deleted
```

```bash
kubectl get pods -n hello-debug
kubectl events -n hello-debug --types=Warning
```

```text
NAME                        READY   STATUS    RESTARTS   AGE
frontend-58c4f7d9b-7lq2x    0/1     Running   0          1m
...
LAST SEEN            TYPE      REASON      OBJECT                         MESSAGE
3s (x12 over 58s)    Warning   Unhealthy   Pod/frontend-58c4f7d9b-7lq2x   Readiness probe failed: Get "http://10.1.0.61:8080/healthz": dial tcp 10.1.0.61:8080: connect: connection refused
```

Die Ursache liegt an der Station Pod: Die Readiness-Probe fragt Port 8080, das Programm lauscht auf 80. Der Pod wird nie bereit, der Service hat keinen bereiten Endpunkt. `kubectl port-forward svc/frontend` hätte trotzdem funktioniert, weil es die Bereitschaft nicht prüft; deshalb der Test-Pod.

Behebung in `playground/k8s/m11-fehler-3/frontend-deployment.yaml`: `readinessProbe.httpGet.port: 80`, dann `kubectl apply -f playground/k8s/m11-fehler-3/`. Der neue Pod wird `1/1`, der Test-Pod liefert die HTML-Seite. In Headlamp stehen dieselben `Readiness probe failed`-Warnungen auf der Pod-Seite unter **Events**. Aufräumen: `kubectl delete namespace hello-debug`.
