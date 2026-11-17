# Lab 11.2 – Lösung: Canary und Blue/Green

Fertige Dateien: [`project/examples/m11-operations/l02-release-strategies/`](../../project/examples/m11-operations/l02-release-strategies/). Pod-Namen, IPs und Zählungen weichen ab.

## Aufgabe 1: Deployment und Service `frontend-v2`

`playground/k8s/frontend-v2-deployment.yaml` (TODO-Stellen ergänzt):

```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-canary
      tier: frontend
      version: v2                       # nur v2-Pods
  template:
    metadata:
      labels:
        app: hello-canary
        tier: frontend
        version: v2
    spec:
      containers:
        - name: frontend
          image: hello-frontend:v2      # neue Version aus Lab 1.3
          imagePullPolicy: Never
          # ... Rest wie im Starter (envFrom hello-config, env APP_COLOR, readinessProbe, resources, Volume data)
```

`playground/k8s/frontend-v2-service.yaml`:

```yaml
spec:
  type: ClusterIP
  selector:
    app: hello-canary
    tier: frontend
    version: v2
  ports:
    - port: 80
      targetPort: 80
```

```bash
kubectl apply -f playground/k8s/frontend-v2-deployment.yaml -f playground/k8s/frontend-v2-service.yaml
kubectl get pods -l version=v2
kubectl get endpointslices -l kubernetes.io/service-name=frontend-v2
```

```text
deployment.apps/frontend-v2 created
service/frontend-v2 created

NAME                           READY   STATUS    RESTARTS   AGE
frontend-v2-6b9c7d5f8d-tq7mz   1/1     Running   0          15s

NAME                ADDRESSTYPE   PORTS   ENDPOINTS   AGE
frontend-v2-p8x4c   IPv4          80      10.1.0.74   15s
```

`version: v2` steht hier ausnahmsweise im Selector, weil Deployment und Service genau eine Version meinen. `app: hello-canary` verhindert, dass der Service `hello-frontend` des Charts den v2-Pod mit aufnimmt.

## Aufgabe 2: Canary-Route mit 90/10

`playground/k8s/canary-route.yaml`:

```yaml
  rules:
    - backendRefs:
        - name: hello-frontend          # v1 aus dem Helm-Release
          port: 80
          weight: 90
        - name: frontend-v2             # v2
          port: 80
          weight: 10
```

```bash
kubectl apply -f playground/k8s/canary-route.yaml
kubectl describe httproute hello-canary
```

```text
httproute.gateway.networking.k8s.io/hello-canary created
...
Status:
  Parents:
    Conditions:
      Message:               Route is accepted
      Reason:                Accepted
      Status:                True
      Type:                  Accepted
      Message:               Resolved all the Object references for the Route
      Reason:                ResolvedRefs
      Status:                True
      Type:                  ResolvedRefs
    Controller Name:         gateway.envoyproxy.io/gatewayclass-controller
    Parent Ref:
      Name:       hello-gateway
      Namespace:  gateway
```

Im Browser zeigt `http://canary.hello.localhost` meist „Hello-App v1" in der Farbe aus `hello-config`, ab und zu „Hello-App v2" auf hellgrünem Hintergrund. Die Farbe von v2 setzt der `env`-Eintrag im Deployment `frontend-v2`; er hat Vorrang vor demselben Schlüssel aus `envFrom`.

## Aufgabe 3: Verteilung bei 90/10

```bash
for i in $(seq 1 50); do curl -s http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'; done | sort | uniq -c
```

```text
  46 Hello-App v1
   4 Hello-App v2
```

Erwartet sind etwa 45 zu 5. Jede Anfrage wird einzeln nach Gewicht ausgelost; bei 50 Anfragen sind 1 bis 10 Treffer für v2 normal.

## Aufgabe 4: Verteilung bei 50/50

```yaml
          weight: 50                    # hello-frontend
          weight: 50                    # frontend-v2
```

```bash
kubectl apply -f playground/k8s/canary-route.yaml
for i in $(seq 1 50); do curl -s http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'; done | sort | uniq -c
```

```text
httproute.gateway.networking.k8s.io/hello-canary configured
  27 Hello-App v1
  23 Hello-App v2
```

Envoy Gateway übernimmt die neuen Gewichte nach wenigen Sekunden; eine Zählung direkt nach `apply` kann noch einige Anfragen mit den alten Gewichten enthalten.

## Aufgabe 5: Umstieg auf 0/100

```yaml
          weight: 0                     # hello-frontend
          weight: 100                   # frontend-v2
```

```bash
kubectl apply -f playground/k8s/canary-route.yaml
for i in $(seq 1 50); do curl -s http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'; done | sort | uniq -c
curl -s http://hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'
kubectl get endpointslices -l kubernetes.io/service-name=hello-frontend
```

```text
httproute.gateway.networking.k8s.io/hello-canary configured
  50 Hello-App v2
Hello-App v1
NAME                   ADDRESSTYPE   PORTS   ENDPOINTS             AGE
hello-frontend-9fz2k   IPv4          80      10.1.0.41,10.1.0.42   2h
```

- Ein Gewicht von 0 schickt keine Anfragen mehr an `hello-frontend`, der Service bleibt aber bestehen. Der Rückweg ist ein `apply` mit 100/0.
- `hello.localhost` nutzt die Route aus dem Chart und zeigt weiter v1. Um v2 dort dauerhaft zu machen, folgt der nächste Schritt über Helm: `helm upgrade hello playground/hello -n hello --reuse-values --set frontend.image.tag=v2` (Lab 9.3), danach können `frontend-v2` und `hello-canary` gelöscht werden.
- Die EndpointSlice von `hello-frontend` enthält nur die Release-Pods (Anzahl je nach `frontend.replicas`), nicht den v2-Pod.

## Erweiterung: A/B-Test per Header

```yaml
  rules:
    - matches:
        - headers:
            - name: x-version
              value: v2
      backendRefs:
        - name: frontend-v2
          port: 80
    - backendRefs:
        - name: hello-frontend
          port: 80
          weight: 100
        - name: frontend-v2
          port: 80
          weight: 0
```

```bash
kubectl apply -f playground/k8s/canary-route.yaml
curl -s -H "x-version: v2" http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'
curl -s http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'
```

```text
httproute.gateway.networking.k8s.io/hello-canary configured
Hello-App v2
Hello-App v1
```

Header-Namen vergleicht die Gateway API ohne Rücksicht auf Groß- und Kleinschreibung; `X-Version: v2` trifft dieselbe Regel.
