# Lab 5.3 – Lösung: HTTP-Routing mit der Gateway API

Alle Befehle im Ordner `project/`. Namen mit Hash, IPs und Zeiten weichen ab.

## Aufgabe 1: Envoy Gateway installieren

```bash
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.10.0/install.yaml
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
kubectl get pods -n envoy-gateway-system
```

```text
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io serverside-applied
…
namespace/envoy-gateway-system serverside-applied
deployment.apps/envoy-gateway serverside-applied
…
deployment.apps/envoy-gateway condition met

NAME                             READY   STATUS    RESTARTS   AGE
envoy-gateway-7d9f5c8b6d-qx2lm   1/1     Running   0          48s
```

## Aufgabe 2: Frontend-Service zurück auf ClusterIP

```yaml
# playground/k8s/frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: hello
    tier: frontend
spec:
  type: ClusterIP
  selector:
    app: hello
    tier: frontend
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
```

```bash
kubectl apply -f playground/k8s/frontend-service.yaml
kubectl get service frontend
```

```text
service/frontend configured

NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
frontend   ClusterIP   10.104.12.200   <none>        80/TCP    25m
```

Meldet `apply` einen Fehler zu `nodePort`: `kubectl delete service frontend` und die Datei erneut anwenden.

## Aufgabe 3: GatewayClass und Gateway

```bash
cp starters/m05-l03-gateway.yaml playground/k8s/gateway.yaml
```

Ergänzte TODOs in `playground/k8s/gateway.yaml`:

```yaml
spec:
  gatewayClassName: eg
  listeners:
    - name: http
      protocol: HTTP
      port: 80
```

```bash
kubectl apply -f playground/k8s/gateway.yaml
kubectl get gatewayclass
kubectl get gateway -n gateway
kubectl get service -n envoy-gateway-system
```

```text
namespace/gateway created
gatewayclass.gateway.networking.k8s.io/eg created
gateway.gateway.networking.k8s.io/hello-gateway created

NAME   CONTROLLER                                      ACCEPTED   AGE
eg     gateway.envoyproxy.io/gatewayclass-controller   True       6s

NAME            CLASS   ADDRESS     PROGRAMMED   AGE
hello-gateway   eg      localhost   True         6s

NAME                                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                            AGE
envoy-gateway                          ClusterIP      10.97.180.12    <none>        18000/TCP,18001/TCP,18002/TCP,19001/TCP,9443/TCP   2m
envoy-gateway-hello-gateway-1d5c2a7e   LoadBalancer   10.108.66.140   localhost     80:30652/TCP                                       6s
```

`PROGRAMMED` kann einige Sekunden `Unknown` zeigen, bis der Envoy-Pod läuft. Der Service-Name setzt sich aus `envoy-<Namespace>-<Gateway>-<Hash>` zusammen.

## Aufgabe 4: HTTPRoute für das Frontend

```bash
cp starters/m05-l03-httproute.yaml playground/k8s/httproute.yaml
```

```yaml
# playground/k8s/httproute.yaml (Zwischenstand)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello
spec:
  parentRefs:
    - name: hello-gateway
      namespace: gateway
  hostnames:
    - hello.localhost
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: frontend
          port: 80
```

```bash
kubectl apply -f playground/k8s/httproute.yaml
kubectl get httproute
```

```text
httproute.gateway.networking.k8s.io/hello created

NAME    HOSTNAMES             AGE
hello   ["hello.localhost"]   3s
```

`http://hello.localhost` zeigt die grüne Seite „Hello-App v2"; Frontend- und Backend-Pod wechseln beim Neuladen.

## Aufgabe 5: Zweite Regel für /api

```yaml
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      backendRefs:
        - name: backend
          port: 80
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: frontend
          port: 80
```

```bash
kubectl apply -f playground/k8s/httproute.yaml
curl http://hello.localhost/api
curl http://hello.localhost/api
kubectl describe httproute hello
```

```text
httproute.gateway.networking.k8s.io/hello configured

{"ip":"10.1.0.25","pod":"backend-5d7c9f6b8b-9tq7d","time":"11:42:03","version":"v1"}
{"ip":"10.1.0.24","pod":"backend-5d7c9f6b8b-4xk2p","time":"11:42:05","version":"v1"}
```

Ausschnitt aus `describe`:

```text
Status:
  Parents:
    Conditions:
      Message:  Route is accepted
      Reason:   Accepted
      Status:   True
      Type:     Accepted
      Message:  Resolved all the Object references for the Route
      Reason:   ResolvedRefs
      Status:   True
      Type:     ResolvedRefs
    Controller Name:  gateway.envoyproxy.io/gatewayclass-controller
    Parent Ref:
      Name:       hello-gateway
      Namespace:  gateway
```

Die Reihenfolge der Regeln ist egal: Bei `PathPrefix` gewinnt der längste passende Pfad.

## Erweiterung: Anfragen ohne passende Regel

```bash
curl -i http://hello.localhost/gibt-es-nicht
curl -i http://localhost/
```

```text
HTTP/1.1 404 NOT FOUND
server: envoy
…
HTTP/1.1 404 Not Found
date: …
content-length: 0
```

Der erste Aufruf geht über die Regel `/` ans Frontend; die Flask-App kennt den Pfad nicht und antwortet selbst mit `404 NOT FOUND`. Der zweite erreicht Envoy, aber keine Route kennt den Hostnamen `localhost`; Envoy antwortet mit einem leeren `404`.
