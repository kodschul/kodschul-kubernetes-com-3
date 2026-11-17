# Lab 8.2 – Übung: Requests, Limits und QoS

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — Frontend und Backend haben Requests und Limits (QoS `Burstable`); Lab 8.3 nutzt den CPU-Request des Frontends als Bezugsgröße für das Autoscaling.

## Vorbereitung

- Zwei Terminals im Ordner `project/` öffnen.
- Starter: [`project/starters/m08-l02-frontend-deployment.yaml`](../../project/starters/m08-l02-frontend-deployment.yaml), [`project/starters/m08-l02-backend-deployment.yaml`](../../project/starters/m08-l02-backend-deployment.yaml)
- Arbeitsdateien: `project/playground/k8s/frontend-deployment.yaml`, `project/playground/k8s/backend-deployment.yaml`
- Prüfen: `kubectl get pods -l app=hello` zeigt alle Frontend- und Backend-Pods mit `1/1`.
- Stand aus Lab 8.1 wiederherstellen (falls nötig): `kubectl apply -f examples/m08-health-resources/l01-probes/`

## Aufgaben

1. Kopiere beide Starter nach `playground/k8s/` (als `frontend-deployment.yaml` und `backend-deployment.yaml`), ergänze die Werte für Requests und Limits und wende beide Dateien an. Warte mit `kubectl rollout status` auf beide Deployments.
2. Zeige die QoS-Klassen mit `kubectl get pods -l app=hello -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass` und die reservierten Ressourcen des Nodes mit `kubectl describe node docker-desktop` (Abschnitt `Allocated resources`) an.
3. Setze im Frontend `requests.memory` und `limits.memory` auf `16Mi`, wende die Datei an und beobachte im zweiten Terminal `kubectl get pods -l tier=frontend -w` etwa eine Minute lang. Lies danach mit `kubectl describe pod <neuer Pod>` den Abschnitt `Last State`.
4. Setze die Werte zurück auf `64Mi` und `128Mi`, wende die Datei an und warte mit `kubectl rollout status deployment/frontend`, bis der Rollout fertig ist.
5. Erhöhe das CPU-Limit eines laufenden Frontend-Pods ohne Neustart auf `800m`:
   `kubectl patch pod <pod> --subresource resize --patch '{"spec":{"containers":[{"name":"frontend","resources":{"limits":{"cpu":"800m"}}}]}}'`
   Prüfe mit den drei `jsonpath`-Befehlen aus der Theorie den gewünschten Wert, den umgesetzten Wert und die Neustarts. Zeige danach mit `kubectl get deployment frontend -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}'` den Wert im Deployment an.

## Checkpoint

- Aufgabe 2: alle Frontend- und Backend-Pods `Burstable`; `Allocated resources` enthält die Requests (3 × 100m + 3 × 50m CPU aus der Hello-App plus Systempods).
- Aufgabe 3: der neue Pod wechselt zwischen `OOMKilled` und `CrashLoopBackOff`, `Last State: Terminated`, `Reason: OOMKilled`, `Exit Code: 137`; die drei alten Pods laufen weiter, die Seite bleibt erreichbar.
- Aufgabe 4: `deployment "frontend" successfully rolled out`, alle Pods `1/1`.
- Aufgabe 5: `spec` und `status` zeigen `800m`, `restartCount` bleibt `0`; das Deployment zeigt weiter `500m`.

## Abschlusskriterien

- Beide Arbeitsdateien enthalten `resources` mit den Werten aus der Theorie; `kubectl get pods -l app=hello` zeigt alle Pods `1/1`.

## Erweiterung

Lösche den Pod aus Aufgabe 5 mit `kubectl delete pod <pod>` und prüfe beim Ersatz-Pod `limits.cpu` mit `jsonpath`: Der neue Pod hat wieder den Wert aus dem Deployment.

## Fallback

- `error: unknown flag: --subresource` oder `invalid subresource`: `kubectl version` prüfen; In-place-Resize braucht kubectl ab 1.32 und einen Cluster ab 1.33 (stabil ab 1.35).
- Fertiger Stand: `kubectl apply -f examples/m08-health-resources/l02-resources/`
