# Lab 6.3 – Übung: Namespaces für Umgebungen

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — zusätzlich laufen die Hello-App in `hello-dev` (grün) und `hello-prod` (blau); der Stand in `hello` bleibt unverändert. Ab Lab 7.1 geht es im Namespace `hello` weiter.

## Vorbereitung

- Terminal im Ordner `project/`; Stand aus Lab 6.2 im Namespace `hello`.
- Starter: [`project/starters/m06-l03-namespaces.yaml`](../../project/starters/m06-l03-namespaces.yaml), [`project/starters/m06-l03-configmap.yaml`](../../project/starters/m06-l03-configmap.yaml)
- Arbeitsdateien: `project/playground/k8s/namespaces.yaml`, `project/playground/k8s/dev/configmap.yaml`, `project/playground/k8s/prod/configmap.yaml`
- Geteilte Manifeste aus den Labs 4.2 bis 6.2: `backend-deployment.yaml`, `backend-service.yaml`, `frontend-deployment.yaml`, `frontend-service.yaml` in `playground/k8s/`; keines davon enthält `namespace:`.
- Stand aus Lab 6.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m06-configuration/l02-secrets/`

## Aufgaben

1. Kopiere den Namespace-Starter nach `playground/k8s/namespaces.yaml`, ergänze `hello-prod` und wende die Datei an. Prüfe mit `kubectl get namespaces -l app=hello`.
2. Lege die Ordner an (`mkdir -p playground/k8s/dev playground/k8s/prod`), kopiere den ConfigMap-Starter in beide Ordner als `configmap.yaml` und setze `APP_COLOR` auf `lightgreen` (dev) und `lightblue` (prod).
3. Lege das Secret in beiden Namespaces an: `kubectl create secret generic hello-secret --from-literal=admin-password=uebung-2026 -n hello-dev` und dasselbe mit `-n hello-prod`.
4. Wende die geteilten Manifeste und die passende ConfigMap je Namespace an (Befehl aus der Theorie, einmal mit `-n hello-dev` und `dev/`, einmal mit `-n hello-prod` und `prod/`). Prüfe mit `kubectl get deployments -A -l app=hello`.
5. Starte in zwei weiteren Terminals `kubectl port-forward -n hello-dev svc/frontend 8081:80` und `kubectl port-forward -n hello-prod svc/frontend 8082:80`, öffne `http://localhost:8081` und `http://localhost:8082`. Rufe danach aus `hello-dev` das Backend von `hello-prod` auf: `kubectl run tmp -n hello-dev --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- http://backend.hello-prod.svc.cluster.local`.

## Checkpoint

- `kubectl get namespaces -l app=hello` listet `hello-dev` und `hello-prod`.
- `kubectl get deployments -A -l app=hello` zeigt je zwei Deployments in `hello`, `hello-dev` und `hello-prod`, alle `READY 3/3`.
- `http://localhost:8081` ist grün, `http://localhost:8082` blau; beide zeigen „Hello-App v2", eine Backend-Antwort und `Passwort gesetzt`. `http://hello.localhost` bleibt gelb bzw. rosa aus Lab 6.1.
- Der Test-Pod aus `hello-dev` erhält JSON mit dem Namen eines Backend-Pods aus `hello-prod` (`kubectl get pods -n hello-prod -l tier=backend` zum Vergleich).

## Abschlusskriterien

- `dev/configmap.yaml` und `prod/configmap.yaml` sind die einzigen Dateien, die sich zwischen den Umgebungen unterscheiden.
- Beide Umgebungen laufen nebeneinander und sind an der Farbe unterscheidbar.

## Erweiterung

Lege die ResourceQuota `dev-limits` aus der Theorie in `hello-dev` an, skaliere das Frontend dort mit `kubectl scale deployment frontend -n hello-dev --replicas=8` und lies `kubectl describe resourcequota dev-limits -n hello-dev` sowie `kubectl get events -n hello-dev --field-selector reason=FailedCreate`. Skaliere danach zurück auf 3 und lösche die Quota mit `kubectl delete resourcequota dev-limits -n hello-dev`.

## Fallback

- Rechner mit wenig Speicher: beide Umgebungen mit `kubectl scale deployment backend frontend -n hello-dev --replicas=1` (und `-n hello-prod`) verkleinern.
- `busybox:1.37` lässt sich nicht laden: `kubectl exec -n hello-dev deploy/frontend -- wget -qO- http://backend.hello-prod.svc.cluster.local`.
- Fertiger Stand zum Vergleich: [`project/examples/m06-configuration/l03-environments/`](../../project/examples/m06-configuration/l03-environments/). Anwenden mit:
  `kubectl apply -f examples/m06-configuration/l03-environments/namespaces.yaml`, dann
  `kubectl apply -n hello-dev -f examples/m06-configuration/l03-environments/ -f examples/m06-configuration/l03-environments/dev/` und dasselbe mit `-n hello-prod` und `prod/` (enthält das Secret mit Übungswert).
