# Lab 8.3 – Übung: Horizontal Pod Autoscaler

**Dauer:** ca. 15 Minuten (davon 5 Minuten Warten auf das Herunterskalieren)
**Ändert die Hello-App-Projektbasis?** Ja — metrics-server im Cluster, HPA `frontend` (1–5 Pods, 50 % CPU); `replicas` steht nicht mehr im Frontend-Deployment.

## Vorbereitung

- Zwei Terminals im Ordner `project/` öffnen.
- Starter: [`project/starters/m08-l03-hpa.yaml`](../../project/starters/m08-l03-hpa.yaml)
- Arbeitsdateien: `project/playground/k8s/hpa.yaml` (neu), `project/playground/k8s/frontend-deployment.yaml`
- Prüfen: `kubectl get pods -l app=hello -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass` zeigt `Burstable` für Frontend und Backend.
- Stand aus Lab 8.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m08-health-resources/l02-resources/`

## Aufgaben

1. Installiere den metrics-server mit den drei Befehlen aus der Theorie (`kubectl apply`, `kubectl patch`, `kubectl rollout status`). Zeige nach etwa einer Minute `kubectl top nodes` und `kubectl top pods` an.
2. Lösche in `playground/k8s/frontend-deployment.yaml` die Zeile `replicas: 3` und wende die Datei an. Kopiere den HPA-Starter nach `playground/k8s/hpa.yaml`, ergänze die TODOs und wende ihn an. Zeige den HPA mit `kubectl get hpa frontend` an.
3. Starte im zweiten Terminal `kubectl get hpa frontend -w`. Starte im ersten Terminal den Lastgenerator:
   `kubectl run load --image=busybox:1.37 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://frontend/work; done"`
4. Beobachte drei bis vier Minuten lang `TARGETS` und `REPLICAS` im zweiten Terminal; zeige zwischendurch `kubectl top pods -l tier=frontend` und `kubectl get pods -l tier=frontend` an.
5. Beende die Last mit `kubectl delete pod load` und beobachte das zweite Terminal, bis `REPLICAS` wieder `1` zeigt (gut 5 Minuten). Zeige danach mit `kubectl describe hpa frontend` die Events an.

## Checkpoint

- Aufgabe 1: `kubectl top pods` zeigt für jeden Hello-Pod CPU in Millicores und Speicher in Mi.
- Aufgabe 2: `TARGETS cpu: 1%/50%` (oder ähnlich niedrig), `MINPODS 1`, `MAXPODS 5`.
- Aufgabe 4: `TARGETS` steigt deutlich über `50%`, `REPLICAS` wächst bis `5`; alle neuen Pods werden `1/1`.
- Aufgabe 5: `TARGETS` fällt sofort, `REPLICAS` sinkt erst nach etwa 5 Minuten; die Events zeigen `New size: 5; reason: cpu resource utilization (percentage of request) above target` und später `New size: 1; reason: All metrics below target`.

## Abschlusskriterien

- `kubectl get hpa frontend` existiert und zeigt `REPLICAS 1` ohne Last.
- `playground/k8s/frontend-deployment.yaml` enthält kein Feld `replicas`; `playground/k8s/hpa.yaml` existiert.

## Erweiterung

Ergänze in `playground/k8s/hpa.yaml` unter `spec` ein schnelleres Herunterskalieren:

```yaml
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 60
```

Wende die Datei an, wiederhole Aufgabe 3 bis 5 und vergleiche die Zeit bis `REPLICAS 1`.

## Fallback

- Download von GitHub gesperrt (Proxy): `components.yaml` auf einem Rechner mit Zugang herunterladen und mit `kubectl apply -f components.yaml` anwenden; der metrics-server lädt sein Image von `registry.k8s.io`.
- `busybox:1.37` nicht ladbar: mit `docker pull busybox:1.37` (ggf. nach `docker login`) vorab laden.
- Steigt die Last nicht über 50 %: einen zweiten Lastgenerator mit dem Namen `load2` starten und später ebenfalls löschen.
- Fertiger Stand: `kubectl apply -f examples/m08-health-resources/l03-autoscaling/` (metrics-server separat installieren)
