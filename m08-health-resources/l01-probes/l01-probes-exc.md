# Lab 8.1 – Übung: Liveness, Readiness und Startup Probes

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — Frontend und Backend haben eine Readiness- und eine Liveness-Probe auf `/healthz`; Lab 8.2 ergänzt Ressourcen.

## Vorbereitung

- Zwei Terminals im Ordner `project/` öffnen.
- Starter: [`project/starters/m08-l01-frontend-deployment.yaml`](../../project/starters/m08-l01-frontend-deployment.yaml), [`project/starters/m08-l01-backend-deployment.yaml`](../../project/starters/m08-l01-backend-deployment.yaml)
- Arbeitsdateien: `project/playground/k8s/frontend-deployment.yaml`, `project/playground/k8s/backend-deployment.yaml`
- Prüfen: `kubectl get deployments` zeigt `backend 3/3` und `frontend 3/3`.
- Stand aus Lab 7.3 wiederherstellen (falls nötig): `kubectl apply -f examples/m07-storage/l03-workload-types/`

## Aufgaben

1. Kopiere beide Starter nach `playground/k8s/` (als `frontend-deployment.yaml` und `backend-deployment.yaml`), ergänze die TODOs und wende beide Dateien an. Warte mit `kubectl rollout status deployment/frontend` und `kubectl rollout status deployment/backend` und zeige die Probes mit `kubectl describe deployment frontend | grep -E "Liveness|Readiness"` an.
2. Starte im zweiten Terminal `kubectl get pods -l tier=frontend -w`. Wähle im ersten Terminal einen Frontend-Pod und löse dort den Ausfall aus: `kubectl exec <pod> -- wget -qO- http://localhost/fail`.
3. Zeige, sobald der Pod `0/1` meldet, mit `kubectl describe endpointslices -l kubernetes.io/service-name=frontend` die Endpoints mit ihren `Conditions` an und rufe die Seite fünfmal mit `curl -s http://hello.localhost/ | grep Frontend-Pod` auf.
4. Warte, bis der Pod im zweiten Terminal `RESTARTS 1` und wieder `1/1` zeigt, und lies mit `kubectl describe pod <pod>` die Events unten.
5. Ändere in `playground/k8s/frontend-deployment.yaml` den `path` der Readiness-Probe auf `/nope`, wende die Datei an und starte `kubectl rollout status deployment/frontend` (nach ca. 30 Sekunden mit **Strg+C** abbrechen). Prüfe mit `kubectl get pods -l tier=frontend` und `curl -s http://hello.localhost/ | grep Hello-App` den Zustand, setze den Pfad danach zurück auf `/healthz` und wende die Datei erneut an.

## Checkpoint

- Aufgabe 1: `Liveness: http-get http://:80/healthz … period=10s #success=1 #failure=3` und `Readiness: http-get http://:80/healthz … period=5s #success=1 #failure=2`.
- Aufgabe 2: nach ca. 10 Sekunden zeigt der gewählte Pod `READY 0/1`.
- Aufgabe 3: die IP des gewählten Pods steht mit `Ready: false` in der EndpointSlice, die beiden anderen mit `Ready: true`; die Seite antwortet jedes Mal, nur von den anderen beiden Pods.
- Aufgabe 4: Events `Readiness probe failed: HTTP probe failed with statuscode: 500`, `Liveness probe failed: …` und `Container frontend failed liveness probe, will be restarted`.
- Aufgabe 5: drei alte Pods `1/1`, ein neuer Pod `0/1`; die Seite läuft weiter. Nach dem Zurücksetzen meldet `kubectl rollout status` `successfully rolled out`.

## Abschlusskriterien

- `kubectl get pods -l app=hello` zeigt alle Frontend- und Backend-Pods mit `1/1`.
- Beide Arbeitsdateien enthalten `readinessProbe` und `livenessProbe` auf `/healthz`.

## Erweiterung

Stelle einen langsamen Start nach: Ergänze im Frontend-Container unter `envFrom` einen Abschnitt `env` mit `- name: STARTUP_DELAY` und `value: "45"`, wende die Datei an und beobachte den neuen Pod mit `kubectl get pods -l tier=frontend -w` eine Minute lang. Ergänze danach eine `startupProbe` (`httpGet /healthz`, Port 80, `periodSeconds: 5`, `failureThreshold: 12`), wende erneut an und vergleiche. Entferne zum Schluss `env` und `startupProbe` wieder und wende die Datei an.

## Fallback

- `wget` im Container nicht verfügbar: `kubectl port-forward pod/<pod> 8090:80` im zweiten Terminal starten und `curl http://localhost:8090/fail` aufrufen.
- Fertiger Stand: `kubectl apply -f examples/m08-health-resources/l01-probes/`
