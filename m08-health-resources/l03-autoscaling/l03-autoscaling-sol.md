# Lab 8.3 – Lösung: Horizontal Pod Autoscaler

Alle Befehle laufen im Ordner `project/`. Namen, Zeiten und Messwerte weichen ab.

## Aufgabe 1: metrics-server installieren

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.1/components.yaml
kubectl patch deployment metrics-server -n kube-system --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl rollout status deployment/metrics-server -n kube-system
kubectl top nodes
kubectl top pods
```

```text
serviceaccount/metrics-server created
...
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
deployment.apps/metrics-server patched
deployment "metrics-server" successfully rolled out

NAME             CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
docker-desktop   412m         5%       2675Mi          34%

NAME                        CPU(cores)   MEMORY(bytes)
backend-7d9f6c5b8-2xq7n     1m           29Mi
backend-7d9f6c5b8-8kd4w     1m           29Mi
backend-7d9f6c5b8-vt5mj     1m           30Mi
frontend-6f8d7c9b5-4hx2p    1m           38Mi
frontend-6f8d7c9b5-k9w3z    1m           37Mi
frontend-6f8d7c9b5-r7m5t    1m           38Mi
```

Meldet `kubectl top` `error: Metrics API not available`, ist der metrics-server noch nicht bereit: eine Minute warten. Bleibt er `0/1`, zeigt `kubectl logs -n kube-system deployment/metrics-server` meist einen Zertifikatsfehler; dann fehlt der Patch.

## Aufgabe 2: replicas entfernen und HPA anlegen

```bash
# Zeile "replicas: 3" in playground/k8s/frontend-deployment.yaml löschen
kubectl apply -f playground/k8s/frontend-deployment.yaml
cp starters/m08-l03-hpa.yaml playground/k8s/hpa.yaml
# TODOs ergänzen (siehe unten)
kubectl apply -f playground/k8s/hpa.yaml
kubectl get hpa frontend
```

```yaml
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

```text
deployment.apps/frontend configured
horizontalpodautoscaler.autoscaling/frontend created
NAME       REFERENCE             TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
frontend   Deployment/frontend   cpu: 1%/50%   1         5         1          20s
```

Ohne `replicas` im Manifest setzt `kubectl apply` das Deployment einmalig auf den Standardwert 1; ab jetzt bestimmt der HPA. Gleichwertig zum YAML: `kubectl autoscale deployment frontend --cpu=50% --min=1 --max=5`.

Vollständige Dateien: [`examples/m08-health-resources/l03-autoscaling/`](../../project/examples/m08-health-resources/l03-autoscaling/)

## Aufgabe 3: Last erzeugen

```bash
# Terminal 2
kubectl get hpa frontend -w
# Terminal 1
kubectl run load --image=busybox:1.37 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://frontend/work; done"
```

```text
pod/load created
```

Der Pod `load` ruft in einer Endlosschleife `http://frontend/work` auf (Service `frontend`, Lab 5.1); jeder Aufruf kostet das Frontend etwa 0,2 Sekunden CPU.

## Aufgabe 4: Hochskalieren beobachten

Terminal 2:

```text
NAME       REFERENCE             TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
frontend   Deployment/frontend   cpu: 1%/50%     1         5         1          2m
frontend   Deployment/frontend   cpu: 412%/50%   1         5         1          2m45s
frontend   Deployment/frontend   cpu: 412%/50%   1         5         5          3m
frontend   Deployment/frontend   cpu: 168%/50%   1         5         5          3m15s
frontend   Deployment/frontend   cpu: 98%/50%    1         5         5          4m
```

```bash
kubectl top pods -l tier=frontend
kubectl get pods -l tier=frontend
```

```text
NAME                       CPU(cores)   MEMORY(bytes)
frontend-6f8d7c9b5-4hx2p   102m         40Mi
frontend-6f8d7c9b5-8mzq1   97m          39Mi
frontend-6f8d7c9b5-c2vt9   99m          39Mi
frontend-6f8d7c9b5-n4d7k   95m          39Mi
frontend-6f8d7c9b5-x8wq3   101m         39Mi

NAME                       READY   STATUS    RESTARTS   AGE
frontend-6f8d7c9b5-4hx2p   1/1     Running   0          12m
frontend-6f8d7c9b5-8mzq1   1/1     Running   0          70s
frontend-6f8d7c9b5-c2vt9   1/1     Running   0          70s
frontend-6f8d7c9b5-n4d7k   1/1     Running   0          55s
frontend-6f8d7c9b5-x8wq3   1/1     Running   0          70s
```

Rechnung beim ersten Sprung: aufrunden(1 × 412 / 50) = 9, begrenzt durch `maxReplicas` auf 5. Ein Lastgenerator schickt immer nur eine Anfrage gleichzeitig; die Last verteilt sich auf alle Pods, bleibt aber über dem Ziel, deshalb bleibt es bei 5.

## Aufgabe 5: Last beenden, Herunterskalieren

```bash
kubectl delete pod load
kubectl describe hpa frontend
```

Terminal 2:

```text
frontend   Deployment/frontend   cpu: 2%/50%    1         5         5          6m
frontend   Deployment/frontend   cpu: 1%/50%    1         5         5          9m
frontend   Deployment/frontend   cpu: 1%/50%    1         5         1          11m15s
```

```text
Events:
  Type    Reason             Age    From                       Message
  ----    ------             ----   ----                       -------
  Normal  SuccessfulRescale  9m     horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  15s    horizontal-pod-autoscaler  New size: 1; reason: All metrics below target
```

Die Last fällt sofort, die Pod-Zahl erst nach dem Stabilisierungsfenster von 5 Minuten. So verhindert der HPA, dass kurze Pausen in der Last zu ständigem Auf und Ab führen.

## Erweiterung

```yaml
spec:
  ...
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 60
```

Mit 60 Sekunden sinkt `REPLICAS` etwa eine Minute nach dem Ende der Last auf 1. Für Produktion ist ein längeres Fenster meist sinnvoller, weil Pods nicht ständig neu starten sollen.
