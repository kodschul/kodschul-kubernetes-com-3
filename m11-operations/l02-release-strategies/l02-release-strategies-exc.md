# Lab 11.2 – Übung: Canary und Blue/Green

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — im Namespace `hello` kommen Deployment und Service `frontend-v2` sowie die HTTPRoute `hello-canary` dazu; das Helm-Release `hello` bleibt auf `v1`.

## Vorbereitung

- Starter: [`project/starters/m11-l02-frontend-v2-deployment.yaml`](../../project/starters/m11-l02-frontend-v2-deployment.yaml), [`m11-l02-frontend-v2-service.yaml`](../../project/starters/m11-l02-frontend-v2-service.yaml), [`m11-l02-canary-route.yaml`](../../project/starters/m11-l02-canary-route.yaml)
- Arbeitsdateien: `project/playground/k8s/frontend-v2-deployment.yaml`, `frontend-v2-service.yaml`, `canary-route.yaml`
- Terminal im Ordner `project/` (Windows: Git Bash). Namespace dieser Übung: `hello` (Standard-Namespace seit Lab 2.4).
- Ausgangsstand: Helm-Release `hello` in `hello` (Lab 9.2 bis 10.3) und Gateway `hello-gateway` in `gateway` (Lab 5.3). Prüfen:

  ```bash
  kubectl config set-context --current --namespace=hello
  helm list -n hello                                     # Release hello, STATUS deployed
  kubectl get gateway -n gateway                         # hello-gateway, PROGRAMMED True
  kubectl get svc hello-frontend                         # PORT(S) 80/TCP
  kubectl get deploy hello-frontend -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
  docker images hello-frontend                           # Tags v1 und v2 vorhanden
  ```

- Zeigt das Image nicht `hello-frontend:v1`, das Release auf `v1` setzen, damit v1 und v2 unterscheidbar sind:

  ```bash
  helm upgrade hello playground/hello -n hello --reuse-values --set frontend.image.tag=v1
  ```

- Starter kopieren:

  ```bash
  cp starters/m11-l02-frontend-v2-deployment.yaml playground/k8s/frontend-v2-deployment.yaml
  cp starters/m11-l02-frontend-v2-service.yaml    playground/k8s/frontend-v2-service.yaml
  cp starters/m11-l02-canary-route.yaml           playground/k8s/canary-route.yaml
  ```

## Aufgaben

1. Ergänze in `playground/k8s/frontend-v2-deployment.yaml` und `frontend-v2-service.yaml` die `TODO`-Stellen (Image der neuen Version, Label `version`, Selector des Service), wende beide Dateien mit `kubectl apply -f` an und prüfe mit `kubectl get pods -l version=v2` und `kubectl get endpointslices -l kubernetes.io/service-name=frontend-v2`, dass der v2-Pod bereit ist und als Endpunkt erscheint.
2. Trage in `playground/k8s/canary-route.yaml` die Gewichte 90 (v1) und 10 (v2) ein, wende die Datei an und prüfe mit `kubectl describe httproute hello-canary`, dass die Route angenommen ist. Öffne `http://canary.hello.localhost` im Browser und lade die Seite mehrmals neu.
3. Zähle die Verteilung mit 50 Anfragen:

   ```bash
   for i in $(seq 1 50); do curl -s http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'; done | sort | uniq -c
   ```

4. Stelle die Gewichte auf 50/50, wende die Datei erneut an und zähle noch einmal.
5. Schließe den Umstieg ab: Gewichte 0 (v1) und 100 (v2), anwenden, zählen. Rufe danach `http://hello.localhost` auf und vergleiche die Version.

## Checkpoint

- `kubectl get pods -l version=v2` zeigt einen Pod `frontend-v2-…` mit `1/1 Running`.
- `kubectl describe httproute hello-canary` zeigt unter `Status` die Bedingungen `Accepted` und `ResolvedRefs` mit `True`.
- Bei 90/10 liegt v2 in der Zählung meist zwischen 1 und 10 von 50, bei 50/50 um 25.
- Bei 0/100 erscheint nur noch `Hello-App v2` (hellgrüner Hintergrund im Browser).

## Abschlusskriterien

- Die Zählung bei 0/100 lautet `50 Hello-App v2`.
- `http://hello.localhost` zeigt weiterhin `Hello-App v1`: die Canary-Route hat das Helm-Release nicht verändert.
- `kubectl get endpointslices -l kubernetes.io/service-name=hello-frontend` listet nur die Pods des Releases, nicht den v2-Pod.

## Erweiterung

A/B-Test: Ergänze in `playground/k8s/canary-route.yaml` vor der bestehenden Regel eine Regel mit `matches` auf den Header `x-version: v2`, die nur an `frontend-v2` weiterleitet, und setze die Gewichte der zweiten Regel zurück auf 100/0. Prüfe mit `curl -s -H "x-version: v2" http://canary.hello.localhost/ | grep -m1 -o 'Hello-App v[0-9]'` und derselben Anfrage ohne Header.

## Fallback

- Safari oder `*.localhost` funktioniert nicht: `curl -s -H "Host: canary.hello.localhost" http://localhost/` in der Schleife verwenden.
- Gateway fehlt oder ist nicht `PROGRAMMED`: Envoy Gateway wie in Lab 5.3 installieren und `kubectl apply -f examples/m05-services/l03-gateway-api/gateway.yaml` anwenden.
- Release `hello` fehlt oder ist kaputt: Stand aus Lab 9.2 installieren mit `helm upgrade --install hello examples/m09-helm/l02-own-chart/hello -n hello --set frontend.image.tag=v1`.
- Image `hello-frontend:v2` fehlt: `bash build-images.sh`.
- Fertiger Stand dieser Übung: [`project/examples/m11-operations/l02-release-strategies/`](../../project/examples/m11-operations/l02-release-strategies/) mit `kubectl apply -f examples/m11-operations/l02-release-strategies/` (enthält die Gewichte 0/100).
